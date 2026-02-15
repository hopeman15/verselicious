# frozen_string_literal: true

module Verselicious
  class LabelDetector
    def initialize(client:, repo:, pr_number:, label_config:)
      @client = client
      @repo = repo
      @pr_number = pr_number
      @label_config = label_config
    end

    def detect_bump_type
      labels = fetch_labels
      label_names = labels.map(&:name)

      if label_names.include?(@label_config[:major])
        'major'
      elsif label_names.include?(@label_config[:minor])
        'minor'
      elsif label_names.include?(@label_config[:patch])
        'patch'
      end
    end

    private

    def fetch_labels
      @client.labels_for_issue(@repo, @pr_number)
    end
  end
end
