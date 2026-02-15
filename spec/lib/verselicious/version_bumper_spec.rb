# frozen_string_literal: true

RSpec.describe Verselicious::VersionBumper do
  describe '#bump' do
    context 'with major bump' do
      it 'increments major and resets minor and patch' do
        bumper = described_class.new('1.5.3')
        expect(bumper.bump('major')).to eq('2.0.0')
      end

      it 'handles zero version' do
        bumper = described_class.new('0.0.0')
        expect(bumper.bump('major')).to eq('1.0.0')
      end
    end

    context 'with minor bump' do
      it 'increments minor and resets patch' do
        bumper = described_class.new('1.5.3')
        expect(bumper.bump('minor')).to eq('1.6.0')
      end

      it 'handles zero version' do
        bumper = described_class.new('0.0.0')
        expect(bumper.bump('minor')).to eq('0.1.0')
      end
    end

    context 'with patch bump' do
      it 'increments patch' do
        bumper = described_class.new('1.5.3')
        expect(bumper.bump('patch')).to eq('1.5.4')
      end

      it 'handles zero version' do
        bumper = described_class.new('0.0.0')
        expect(bumper.bump('patch')).to eq('0.0.1')
      end
    end

    context 'with invalid bump type' do
      it 'raises ArgumentError' do
        bumper = described_class.new('1.0.0')
        expect { bumper.bump('invalid') }.to raise_error(ArgumentError, /Invalid bump type/)
      end
    end
  end

  describe '#initialize' do
    context 'with invalid version format' do
      it 'raises ArgumentError for non-semver' do
        expect { described_class.new('1.0') }.to raise_error(ArgumentError, /Invalid version format/)
      end

      it 'raises ArgumentError for non-numeric components' do
        expect { described_class.new('a.b.c') }.to raise_error(ArgumentError, /Invalid version component/)
      end
    end
  end
end
