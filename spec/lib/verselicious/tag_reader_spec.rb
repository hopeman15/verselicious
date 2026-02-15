# frozen_string_literal: true

RSpec.describe Verselicious::TagReader do
  let(:prefix) { '' }
  let(:reader) { described_class.new(prefix: prefix) }

  before do
    allow(reader).to receive(:system).with('git', 'fetch', '--force', '--tags', exception: true)
  end

  describe '#latest_version' do
    context 'with existing tags' do
      before { allow(reader).to receive(:`).and_return("1.0.0\n1.2.3\n2.0.0\n") }

      it 'returns the latest version' do
        expect(reader.latest_version).to eq('2.0.0')
      end
    end

    context 'with prefixed tags' do
      let(:prefix) { 'v' }

      before { allow(reader).to receive(:`).and_return("v1.0.0\nv1.2.3\nv2.0.0\n") }

      it 'strips the configured prefix' do
        expect(reader.latest_version).to eq('2.0.0')
      end
    end

    context 'with no tags' do
      before { allow(reader).to receive(:`).and_return('') }

      it 'returns 0.0.0' do
        expect(reader.latest_version).to eq('0.0.0')
      end
    end

    context 'with non-semver tags' do
      let(:prefix) { 'v' }

      before { allow(reader).to receive(:`).and_return("v1.0.0\nv1.0.0-beta\nvfoo\nv2.0.0\n") }

      it 'ignores non-semver tags' do
        expect(reader.latest_version).to eq('2.0.0')
      end
    end

    context 'with mixed prefixed and unprefixed tags' do
      let(:prefix) { 'v' }

      before { allow(reader).to receive(:`).and_return("1.0.0\nv1.2.3\n3.0.0\n") }

      it 'only matches tags with the correct prefix' do
        expect(reader.latest_version).to eq('1.2.3')
      end
    end

    it 'fetches tags before reading them' do
      allow(reader).to receive(:`).and_return('')
      reader.latest_version
      expect(reader).to have_received(:system).with('git', 'fetch', '--force', '--tags', exception: true)
    end
  end
end
