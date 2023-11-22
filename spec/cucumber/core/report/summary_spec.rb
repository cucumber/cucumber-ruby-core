# frozen_string_literal: true

require 'cucumber/core/event_bus'
require 'cucumber/core/events'
require 'cucumber/core/report/summary'
require 'cucumber/core/test/result'
require 'cucumber/core/test/step'

describe Cucumber::Core::Report::Summary do
  subject(:summary) { described_class.new(event_bus) }

  let(:event_bus) { ::Cucumber::Core::EventBus.new(registry) }
  let(:registry) { ::Cucumber::Core::Events.registry }
  let(:passed_result) { ::Cucumber::Core::Test::Result::Passed.new(duration) }
  let(:failed_result) { ::Cucumber::Core::Test::Result::Failed.new(duration, exception) }
  let(:pending_result) { ::Cucumber::Core::Test::Result::Pending.new(duration) }
  let(:skipped_result) { ::Cucumber::Core::Test::Result::Skipped.new(duration) }
  let(:undefined_result) { ::Cucumber::Core::Test::Result::Undefined.new(duration) }
  let(:duration) { double }
  let(:exception) { double }

  describe 'test case summary' do
    let(:test_case) { double }

    it 'counts passed test cases' do
      event_bus.send(:test_case_finished, test_case, passed_result)

      expect(summary.test_cases.total(:passed)).to eq(1)
      expect(summary.test_cases.total).to eq(1)
    end

    it 'counts failed test cases' do
      event_bus.send(:test_case_finished, test_case, failed_result)

      expect(summary.test_cases.total(:failed)).to eq(1)
      expect(summary.test_cases.total).to eq(1)
    end

    it 'counts pending test cases' do
      event_bus.send(:test_case_finished, test_case, pending_result)

      expect(summary.test_cases.total(:pending)).to eq(1)
      expect(summary.test_cases.total).to eq(1)
    end

    it 'counts skipped test cases' do
      event_bus.send(:test_case_finished, test_case, skipped_result)

      expect(summary.test_cases.total(:skipped)).to eq(1)
      expect(summary.test_cases.total).to eq(1)
    end

    it 'counts undefined test cases' do
      event_bus.send(:test_case_finished, test_case, undefined_result)

      expect(summary.test_cases.total(:undefined)).to eq(1)
      expect(summary.test_cases.total).to eq(1)
    end

    it 'handles flaky test cases' do
      allow(test_case).to receive(:==).and_return(false, true)
      event_bus.send(:test_case_finished, test_case, failed_result)
      event_bus.send(:test_case_finished, test_case, passed_result)

      expect(summary.test_cases.total(:failed)).to eq(0)
      expect(summary.test_cases.total(:flaky)).to eq(1)
      expect(summary.test_cases.total).to eq(1)
    end

    it 'handles flaky with following skip test cases' do
      allow(test_case).to receive(:==).and_return(false, true)
      event_bus.send(:test_case_finished, test_case, failed_result)
      event_bus.send(:test_case_finished, test_case, skipped_result)

      expect(summary.test_cases.total(:failed)).to eq(0)
      expect(summary.test_cases.total(:skipped)).to eq(0)
      expect(summary.test_cases.total(:flaky)).to eq(1)
      expect(summary.test_cases.total).to eq(1)
    end
  end

  describe 'test step summary' do
    context 'with test steps from gherkin steps' do
      let(:test_step) { instance_double(Cucumber::Core::Test::Step, hook?: false) }

      it 'counts passed test steps' do
        event_bus.send(:test_step_finished, test_step, passed_result)

        expect(summary.test_steps.total(:passed)).to eq(1)
        expect(summary.test_steps.total).to eq(1)
      end

      it 'counts failed test cases' do
        event_bus.send(:test_step_finished, test_step, failed_result)

        expect(summary.test_steps.total(:failed)).to eq(1)
        expect(summary.test_steps.total).to eq(1)
      end

      it 'counts pending test cases' do
        event_bus.send(:test_step_finished, test_step, pending_result)

        expect(summary.test_steps.total(:pending)).to eq(1)
        expect(summary.test_steps.total).to eq(1)
      end

      it 'counts skipped test cases' do
        event_bus.send(:test_step_finished, test_step, skipped_result)

        expect(summary.test_steps.total(:skipped)).to eq(1)
        expect(summary.test_steps.total).to eq(1)
      end

      it 'counts undefined test cases' do
        event_bus.send(:test_step_finished, test_step, undefined_result)

        expect(summary.test_steps.total(:undefined)).to eq(1)
        expect(summary.test_steps.total).to eq(1)
      end
    end

    context 'with test steps not from gherkin steps' do
      let(:test_step) { instance_double(Cucumber::Core::Test::Step, hook?: true) }

      it 'ignores test steps not defined by gherkin steps' do
        event_bus.send(:test_step_finished, test_step, passed_result)

        expect(summary.test_steps.total).to eq(0)
      end
    end
  end

  describe '#ok?' do
    let(:test_case) { double }

    it 'passed test cases are ok' do
      event_bus.send(:test_case_finished, test_case, passed_result)

      expect(summary.ok?).to be true
    end

    it 'skipped test cases are ok' do
      event_bus.send(:test_case_finished, test_case, skipped_result)

      expect(summary.ok?).to be true
    end

    it 'failed test cases are not ok' do
      event_bus.send(:test_case_finished, test_case, failed_result)

      expect(summary.ok?).to be false
    end

    it 'pending test cases are not ok if strict is configured for pending tests' do
      event_bus.send(:test_case_finished, test_case, pending_result)

      expect(summary.ok?).to be true
      strict = ::Cucumber::Core::Test::Result::StrictConfiguration.new([:pending])
      expect(summary.ok?(strict: strict)).to be false
    end

    it 'undefined test cases are not ok if strict is configured for undefined tests' do
      event_bus.send(:test_case_finished, test_case, undefined_result)

      expect(summary.ok?).to be true
      strict = ::Cucumber::Core::Test::Result::StrictConfiguration.new([:undefined])
      expect(summary.ok?(strict: strict)).to be false
    end
  end
end
