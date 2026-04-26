# frozen_string_literal: true

require 'octokit'

module Verselicious
  class ReleaseCreator
    PERMISSION_HINT = <<~HINT.strip
      The token cannot write releases to this repository. Verify the token has the required permissions:
        - GITHUB_TOKEN: workflow needs `permissions: contents: write`
        - Classic PAT: `repo` scope (or `public_repo` for public repos only)
        - Fine-grained PAT: "Contents: Read and write" with access to this repository
      See the README "Token permissions" section for details.
    HINT

    class PermissionError < StandardError; end

    def initialize(client:, repo:)
      @client = client
      @repo = repo
    end

    def create(tag:, target_branch:, generate_notes:)
      @client.create_release(
        @repo,
        tag,
        target_commitish: target_branch,
        generate_release_notes: generate_notes,
        name: tag
      )
    rescue Octokit::NotFound, Octokit::Unauthorized => e
      raise PermissionError, "Failed to create release for #{@repo} (#{e.class}: #{e.message}). #{PERMISSION_HINT}"
    end
  end
end
