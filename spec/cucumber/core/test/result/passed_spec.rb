# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'support/duration_matcher'

describe Cucumber::Core::Test::Result::Passed do
  subject(:result) { described_class.new(duration) }

  let(:duration)   { Cucumber::Core::Test::Result::Duration.new(1 * 1_000 * 1_000) }
  let(:visitor) { double }
  let(:args)    { double }

  before do
    allow(visitor).to receive(:duration)
    allow(visitor).to receive(:passed)
  end

  it 'does nothing when appending the backtrace' do
    expect(result.with_appended_backtrace(double)).to eq(result)
  end

  it 'does nothing when filtering the backtrace' do
    expect(result.with_filtered_backtrace(double)).to eq(result)
  end

  describe '.ok?' do
    it { expect(described_class).to be_ok }
  end

  describe '#describe_to' do
    it 'is described as a passing test' do
      expect(visitor).to receive(:passed).with(args)

      result.describe_to(visitor, args)
    end
  end

  describe '#to_message' do
    it 'is a `TestStepResult` message' do
      expect(result.to_message).to be_a Cucumber::Messages::TestStepResult
    end

    it 'has a status' do
      expect(result.to_message.status).to eq(Cucumber::Messages::TestStepResultStatus::PASSED)
    end

    it 'has a duration' do
      expect(result.to_message.duration).to have_attributes(seconds: 0, nanos: 1_000_000)
    end
  end

  it { expect(result.to_sym).to eq(:passed) }
  it { expect(result.to_s).to eq('✓') }

  context 'with the BooleanMethods helper' do
    describe '#ok?' do
      it 'calls the class method' do
        expect(described_class).to receive(:ok?)

        result.ok?
      end
    end

    it { expect(result).not_to be_failed }
    it { expect(result).not_to be_ambiguous }
    it { expect(result).not_to be_flaky }
    it { expect(result).not_to be_undefined }
    it { expect(result).not_to be_pending }
    it { expect(result).not_to be_skipped }
    it { expect(result).to be_passed }
    it { expect(result).not_to be_unknown }
  end
end
