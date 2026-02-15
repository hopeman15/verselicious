# frozen_string_literal: true

module Verselicious
  class TagReader
    def initialize(prefix: '')
      @prefix = prefix
    end

    def latest_version
      fetch_tags
      tag = latest_tag.to_s
      return '0.0.0' if tag.empty?

      tag.delete_prefix(@prefix)
    end

    private

    def fetch_tags
      system('git', 'fetch', '--force', '--tags', exception: true)
    end

    def latest_tag
      semver = /\A\d+\.\d+\.\d+\z/
      `git tag --sort=version:refname`
        .lines
        .map(&:strip)
        .reverse
        .find do |tag|
          tag.start_with?(@prefix) && semver.match?(tag.delete_prefix(@prefix))
        end
    end
  end
end
