# frozen_string_literal: true

RSpec.describe Verselicious::TagReader do
  describe '#latest_version' do
    context 'with existing tags' do
      it 'returns the latest version without prefix' do
        reader = described_class.new
        allow(reader).to receive(:fetch_tags)
        allow(reader).to receive(:latest_tag).and_return('1.2.3')

        expect(reader.latest_version).to eq('1.2.3')
      end

      it 'strips the configured prefix' do
        reader = described_class.new(prefix: 'v')
        allow(reader).to receive(:fetch_tags)
        allow(reader).to receive(:latest_tag).and_return('v1.2.3')

        expect(reader.latest_version).to eq('1.2.3')
      end
    end

    context 'with no tags' do
      it 'returns 0.0.0' do
        reader = described_class.new
        allow(reader).to receive(:fetch_tags)
        allow(reader).to receive(:latest_tag).and_return(nil)

        expect(reader.latest_version).to eq('0.0.0')
      end

      it 'returns 0.0.0 for empty string' do
        reader = described_class.new
        allow(reader).to receive(:fetch_tags)
        allow(reader).to receive(:latest_tag).and_return('')

        expect(reader.latest_version).to eq('0.0.0')
      end
    end
  end
end
