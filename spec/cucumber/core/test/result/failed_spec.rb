# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'support/duration_matcher'

describe Cucumber::Core::Test::Result::Failed do
  subject(:result) { described_class.new(duration, exception) }

  let(:duration)   { Cucumber::Core::Test::Result::Duration.new(1 * 1_000 * 1_000) }
  let(:exception)  { StandardError.new('error message') }
  let(:visitor) { double }
  let(:args) { double }
  let(:filter_class) { double }
  let(:filter) { double }
  let(:filtered_exception) { double }

  before do
    allow(visitor).to receive(:failed)
    allow(visitor).to receive(:duration)
    allow(visitor).to receive(:exception)
  end

  it 'does nothing if step has no backtrace line' do
    result.exception.set_backtrace('exception backtrace')
    step = 'does not respond_to?(:backtrace_line)'

    expect(result.with_appended_backtrace(step).exception.backtrace).to eq(['exception backtrace'])
  end

  it 'appends the backtrace line of the step' do
    result.exception.set_backtrace('exception backtrace')
    step = double
    allow(step).to receive(:backtrace_line).and_return('step_line')

    expect(result.with_appended_backtrace(step).exception.backtrace).to eq(['exception backtrace', 'step_line'])
  end

  it 'applies filters to the exception' do
    # Permit an exception to be filtered and not excluded
    allow(filter_class).to receive(:new).with(result.exception).and_return(filter)
    allow(filter).to receive(:exception).and_return(filtered_exception)

    expect(result.with_filtered_backtrace(filter_class).exception).to eq(filtered_exception)
  end

  describe '.ok?' do
    it { expect(described_class).not_to be_ok }
  end

  describe '#describe_to' do
    it 'is described as a failing test' do
      expect(visitor).to receive(:failed).with(args)

      result.describe_to(visitor, args)
    end

    it 'contains an exception message' do
      expect(visitor).to receive(:exception).with(exception, args)

      result.describe_to(visitor, args)
    end
  end

  describe '#to_message' do
    it 'is a `TestStepResult` message' do
      expect(result.to_message).to be_a Cucumber::Messages::TestStepResult
    end

    it 'has a status' do
      expect(result.to_message.status).to eq(Cucumber::Messages::TestStepResultStatus::FAILED)
    end

    it 'has a duration' do
      expect(result.to_message.duration).to have_attributes(seconds: 0, nanos: 1_000_000)
    end
  end

  it { expect(result.to_sym).to eq(:failed) }
  it { expect(result.to_s).to eq('✗') }

  context 'with the BooleanMethods helper' do
    describe '#ok?' do
      it 'calls the class method' do
        expect(described_class).to receive(:ok?)

        result.ok?
      end
    end

    it { expect(result).to be_failed }
    it { expect(result).not_to be_ambiguous }
    it { expect(result).not_to be_flaky }
    it { expect(result).not_to be_undefined }
    it { expect(result).not_to be_pending }
    it { expect(result).not_to be_skipped }
    it { expect(result).not_to be_passed }
    it { expect(result).not_to be_unknown }
  end
end
