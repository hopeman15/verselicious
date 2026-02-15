# frozen_string_literal: true

module Verselicious
  class ReleaseCreator
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
    end
  end
end
