# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'support/duration_matcher'

describe Cucumber::Core::Test::Result::Undefined do
  subject(:result) { described_class.new }

  let(:visitor) { double }
  let(:args) { double }

  describe '.ok?' do
    it { expect(described_class).not_to be_ok }
  end

  describe '#describe_to' do
    it 'describes itself to a visitor' do
      expect(visitor).to receive(:undefined).with(args)
      expect(visitor).to receive(:duration).with(an_unknown_duration, args)

      result.describe_to(visitor, args)
    end
  end

  describe '#to_message' do
    it 'is a `TestStepResult` message' do
      expect(result.to_message).to be_a Cucumber::Messages::TestStepResult
    end

    it 'has a status' do
      expect(result.to_message.status).to eq(Cucumber::Messages::TestStepResultStatus::UNDEFINED)
    end

    it 'has a duration' do
      expect(result.to_message.duration).to have_attributes(seconds: 0, nanos: 0)
    end
  end

  it { expect(result.to_sym).to eq(:undefined) }
  it { expect(result.to_s).to eq('?') }

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
    it { expect(result).to be_undefined }
    it { expect(result).not_to be_pending }
    it { expect(result).not_to be_skipped }
    it { expect(result).not_to be_passed }
    it { expect(result).not_to be_unknown }
  end
end
