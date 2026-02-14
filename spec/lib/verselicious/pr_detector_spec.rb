# frozen_string_literal: true

RSpec.describe Verselicious::PrDetector do
  let(:client) { instance_double(Octokit::Client) }
  let(:sha) { 'abc123' }

  def build_detector
    described_class.new(client: client, repo: 'owner/repo', sha: sha)
  end

  describe '#detect' do
    it 'returns the PR number from the first associated pull request' do
      pull = double(number: 42)
      allow(client).to receive(:commit_pulls).with('owner/repo', sha).and_return([pull])

      expect(build_detector.detect).to eq(42)
    end

    it 'returns nil when no pull requests are associated' do
      allow(client).to receive(:commit_pulls).with('owner/repo', sha).and_return([])

      expect(build_detector.detect).to be_nil
    end
  end
end
