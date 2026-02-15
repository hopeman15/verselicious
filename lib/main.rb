#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'verselicious'
require 'octokit'

module Verselicious
  class Runner
    def initialize
      @client = Octokit::Client.new(
        access_token: ENV.fetch('INPUT_GITHUB_TOKEN') { raise 'INPUT_GITHUB_TOKEN is not set' },
        api_endpoint: ENV.fetch('GITHUB_API_URL', 'https://api.github.com')
      )
      @repo = ENV.fetch('GITHUB_REPOSITORY') { raise 'GITHUB_REPOSITORY is not set' }
      @sha = ENV.fetch('GITHUB_SHA') { raise 'GITHUB_SHA is not set' }
      @output_file = ENV.fetch('GITHUB_OUTPUT', nil)
      @config = build_config
    end

    def run
      pr_number = detect_pr_number
      return puts('No pull request found for this commit. Skipping.') unless pr_number

      bump_type = detect_bump_type(pr_number)
      return puts('No version bump label found. Skipping.') unless bump_type

      perform_release(bump_type)
    end

    private

    def build_config
      {
        tag_prefix: ENV.fetch('INPUT_TAG_PREFIX', ''),
        target_branch: ENV.fetch('INPUT_TARGET_BRANCH', 'main'),
        generate_notes: ENV.fetch('INPUT_GENERATE_NOTES', 'true') == 'true',
        label_config: %i[major minor patch].to_h do |type|
          [type, ENV.fetch("INPUT_#{type.upcase}_LABEL", type.to_s)]
        end
      }
    end

    def detect_pr_number
      PrDetector.new(client: @client, repo: @repo, sha: @sha).detect
    end

    def detect_bump_type(pr_number)
      LabelDetector.new(
        client: @client, repo: @repo, pr_number: pr_number,
        label_config: @config[:label_config]
      ).detect_bump_type
    end

    def perform_release(bump_type)
      prefix = @config[:tag_prefix]
      previous_version = TagReader.new(prefix: prefix).latest_version
      new_version = VersionBumper.new(previous_version).bump(bump_type)

      puts "Bumping #{bump_type}: #{previous_version} -> #{new_version} (tag: #{prefix}#{new_version})"
      publish_tag("#{prefix}#{new_version}", new_version, previous_version)
    end

    def publish_tag(tag, new_version, previous_version)
      release_url = create_github_release(tag)
      write_github_output('new-version' => new_version, 'previous-version' => previous_version,
                          'tag' => tag, 'release-url' => release_url)
      puts "Release created: #{release_url}"
    end

    def create_github_release(tag)
      ReleaseCreator.new(client: @client, repo: @repo)
                    .create(tag: tag, target_branch: @config[:target_branch],
                            generate_notes: @config[:generate_notes])
                    .html_url
    end

    def write_github_output(results)
      return unless @output_file

      content = results.map { |key, value| "#{key}=#{value}" }.join("\n")
      File.open(@output_file, 'a') { |f| f.puts content }
    end
  end
end

Verselicious::Runner.new.run
