# frozen_string_literal: true

RSpec.describe Verselicious::LabelDetector do
  let(:client) { instance_double(Octokit::Client) }
  let(:label_config) { { major: 'major', minor: 'minor', patch: 'patch' } }

  def build_detector(pr_number: 42)
    described_class.new(client: client, repo: 'owner/repo', pr_number: pr_number, label_config: label_config)
  end

  def stub_labels(*names)
    labels = names.map { |name| double(name: name) }
    allow(client).to receive(:labels_for_issue).and_return(labels)
  end

  describe '#detect_bump_type' do
    it 'returns major when major label is present' do
      stub_labels('major', 'some-other-label')
      expect(build_detector.detect_bump_type).to eq('major')
    end

    it 'returns minor when minor label is present' do
      stub_labels('minor')
      expect(build_detector.detect_bump_type).to eq('minor')
    end

    it 'returns patch when patch label is present' do
      stub_labels('patch')
      expect(build_detector.detect_bump_type).to eq('patch')
    end

    it 'returns nil when no bump label is present' do
      stub_labels('bug', 'documentation')
      expect(build_detector.detect_bump_type).to be_nil
    end

    it 'prioritizes major over minor and patch' do
      stub_labels('major', 'minor', 'patch')
      expect(build_detector.detect_bump_type).to eq('major')
    end

    it 'prioritizes minor over patch' do
      stub_labels('minor', 'patch')
      expect(build_detector.detect_bump_type).to eq('minor')
    end

    context 'with custom label names' do
      let(:label_config) do
        { major: 'major :1st_place_medal:', minor: 'minor :2nd_place_medal:', patch: 'patch :3rd_place_medal:' }
      end

      it 'detects custom label names' do
        stub_labels('major :1st_place_medal:')
        expect(build_detector.detect_bump_type).to eq('major')
      end
    end
  end
end
