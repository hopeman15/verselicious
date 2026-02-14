# frozen_string_literal: true

module Verselicious
  class PrDetector
    def initialize(client:, repo:, sha:)
      @client = client
      @repo = repo
      @sha = sha
    end

    def detect
      pulls = @client.commit_pulls(@repo, @sha)
      pulls.first&.number
    end
  end
end
