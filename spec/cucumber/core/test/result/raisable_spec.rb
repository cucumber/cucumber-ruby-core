# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'support/duration_matcher'

describe Cucumber::Core::Test::Result::Raisable do
  let(:visitor) { double }
  let(:args)    { double }

  subject(:result) { described_class.new }

  context 'with or without backtrace' do
    it 'does nothing if step has no backtrace line' do
      step = 'does not respond_to?(:backtrace_line)'

      expect(result.with_appended_backtrace(step).backtrace).to be_nil
    end
  end

  context 'without backtrace' do
    it 'set the backtrace to the backtrace line of the step' do
      step = double
      allow(step).to receive(:backtrace_line).and_return('step_line')

      expect(result.with_appended_backtrace(step).backtrace).to eq(['step_line'])
    end

    it 'does nothing when filtering the backtrace' do
      expect(result.with_filtered_backtrace(double)).to eq(result)
    end
  end

  context 'with backtrace' do
    subject(:result) { described_class.new('message', 0, 'backtrace') }

    let(:filter_class) { double }
    let(:filter) { double }
    let(:filtered_backtrace) { double }

    before do
      # Permit an exception to be filtered and not excluded
      allow(filter_class).to receive(:new).with(result.exception).and_return(filter)
      allow(filter).to receive(:exception).and_return(filtered_backtrace)
    end

    it 'appends the backtrace line of the step' do
      step = double
      allow(step).to receive(:backtrace_line).and_return('step_line')

      expect(result.with_appended_backtrace(step).backtrace).to eq(%w[backtrace step_line])
    end

    it 'applies filters to the backtrace' do
      expect(result.with_filtered_backtrace(filter_class)).to eq(filtered_backtrace)
    end
  end
end
