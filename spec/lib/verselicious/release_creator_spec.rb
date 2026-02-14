# frozen_string_literal: true

RSpec.describe Verselicious::ReleaseCreator do
  let(:client) { instance_double(Octokit::Client) }
  let(:creator) { described_class.new(client: client, repo: 'owner/repo') }

  describe '#create' do
    it 'creates a release with correct parameters' do
      release = double(html_url: 'https://github.com/owner/repo/releases/tag/1.2.0')

      allow(client).to receive(:create_release).with(
        'owner/repo',
        '1.2.0',
        target_commitish: 'main',
        generate_release_notes: true,
        name: '1.2.0'
      ).and_return(release)

      result = creator.create(tag: '1.2.0', target_branch: 'main', generate_notes: true)
      expect(result.html_url).to eq('https://github.com/owner/repo/releases/tag/1.2.0')
      expect(client).to have_received(:create_release)
    end

    it 'passes tag prefix through to the tag' do
      release = double(html_url: 'https://github.com/owner/repo/releases/tag/v2.0.0')

      allow(client).to receive(:create_release).with(
        'owner/repo',
        'v2.0.0',
        target_commitish: 'develop',
        generate_release_notes: false,
        name: 'v2.0.0'
      ).and_return(release)

      result = creator.create(tag: 'v2.0.0', target_branch: 'develop', generate_notes: false)
      expect(result.html_url).to include('v2.0.0')
      expect(client).to have_received(:create_release)
    end
  end
end
