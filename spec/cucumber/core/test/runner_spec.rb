# frozen_string_literal: true

require 'cucumber/core/test/around_hook'
require 'cucumber/core/test/runner'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'
require 'cucumber/core/test/duration_matcher'

describe Cucumber::Core::Test::Runner do
  let(:test_steps)       { double }
  let(:test_case)        { Cucumber::Core::Test::Case.new(id: double, name: double, test_steps: test_steps, location: double, parent_locations: double, tags: double, language: double) }
  let(:text)             { double }
  let(:location)         { double }
  let(:runner)           { described_class.new(event_bus) }
  let(:event_bus)        { double.as_null_object }
  let(:passing)          { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { :no_op } }
  let(:failing)          { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { raise exception } }
  let(:pending)          { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { raise Cucumber::Core::Test::Result::Pending.new('TODO') } }
  let(:skipping)         { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { raise Cucumber::Core::Test::Result::Skipped.new } }
  let(:undefined)        { Cucumber::Core::Test::Step.new(double, text, double, double) }
  let(:exception)        { StandardError.new('test error') }

  before do
    allow(event_bus).to receive(:test_case_started)
    allow(text).to receive(:empty?)
  end

  context 'when reporting the duration of a test case' do
    before do
      allow(Cucumber::Core::Test::Timer::MonotonicTime).to receive(:time_in_nanoseconds).and_return(525_702_744_080_000, 525_702_744_080_001)
    end

    context 'with a passing test case' do
      let(:test_steps) { [passing] }

      it 'records the nanoseconds duration of the execution on the result' do
        expect(event_bus).to receive(:test_case_finished) do |_reported_test_case, result|
          expect(result.duration).to be_duration(1)
        end
        test_case.describe_to runner
      end
    end

    context 'with a failing test case' do
      let(:test_steps) { [failing] }

      it 'records the duration' do
        expect(event_bus).to receive(:test_case_finished) do |_reported_test_case, result|
          expect(result.duration).to be_duration(1)
        end
        test_case.describe_to runner
      end
    end
  end

  context 'when reporting the exception that failed a test case' do
    let(:test_steps) { [failing] }

    it 'sets the exception on the result' do
      allow(event_bus).to receive(:before_test_case)
      expect(event_bus).to receive(:test_case_finished) do |_reported_test_case, result|
        expect(result.exception).to eq(exception)
      end
      test_case.describe_to runner
    end
  end

  context 'with a single case' do
    context 'without steps' do
      let(:test_steps) { [] }

      it 'emits a test_case_started event before running the test case' do
        expect(event_bus).to receive(:test_case_started).with(test_case)

        test_case.describe_to runner
      end

      it 'emits the test_case_finished event after running the the test case' do
        expect(event_bus).to receive(:test_case_finished) do |reported_test_case, result|
          expect(reported_test_case).to eq(test_case)
          expect(result).to be_undefined
        end
        test_case.describe_to runner
      end
    end

    context 'with steps' do
      context 'with steps that all pass' do
        let(:test_steps) { [passing, passing]  }

        it 'emits the test_case_finished event with a passing result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result).to be_passed
          end
          test_case.describe_to runner
        end
      end

      context 'with an undefined step' do
        let(:test_steps) { [undefined]  }

        it 'emits the test_case_finished event with an undefined result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result).to be_undefined
          end

          test_case.describe_to runner
        end

        it 'sets the message on the result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result.message).to eq('Undefined step: "step name"')
          end
          allow(undefined).to receive(:text).and_return('step name')

          test_case.describe_to runner
        end

        it 'appends the backtrace of the result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result.backtrace).to eq(['step line'])
          end
          allow(undefined).to receive(:backtrace_line).and_return('step line')

          test_case.describe_to runner
        end
      end

      context 'with a pending step' do
        let(:test_steps) { [pending] }

        it 'emits the test_case_finished event with a pending result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result).to be_pending
          end
          test_case.describe_to runner
        end

        it 'appends the backtrace of the result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result.backtrace.last).to eq('step line')
          end
          allow(pending).to receive(:backtrace_line).and_return('step line')

          test_case.describe_to runner
        end
      end

      context 'with a skipping step' do
        let(:test_steps) { [skipping] }

        it 'emits the test_case_finished event with a skipped result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result).to be_skipped
          end
          test_case.describe_to runner
        end

        it 'appends the backtrace of the result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result.backtrace.last).to eq('step line')
          end
          allow(skipping).to receive(:backtrace_line).and_return('step line')

          test_case.describe_to runner
        end
      end

      context 'with failing steps' do
        let(:test_steps) { [failing] }

        it 'emits the test_case_finished event with a failing result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result).to be_failed
          end
          test_case.describe_to runner
        end

        it 'appends the backtrace of the exception of the result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result.exception.backtrace.last).to eq('step line')
          end
          allow(failing).to receive(:backtrace_line).and_return('step line')

          test_case.describe_to runner
        end
      end

      context 'with an initial failing step' do
        let(:test_steps) { [failing, passing] }

        it 'emits the test_step_finished event with a failed result' do
          expect(event_bus).to receive(:test_step_finished).with(failing, anything) do |_test_step, result|
            expect(result).to be_failed
          end
          test_case.describe_to runner
        end

        it 'emits a test_step_finished event with a skipped result' do
          expect(event_bus).to receive(:test_step_finished).with(passing, anything) do |_test_step, result|
            expect(result).to be_skipped
          end
          test_case.describe_to runner
        end

        it 'emits a test_case_finished event with a failed result' do
          expect(event_bus).to receive(:test_case_finished) do |_test_case, result|
            expect(result).to be_failed
            expect(result.exception).to eq exception
          end
          test_case.describe_to runner
        end

        it 'skips, rather than executing the second step' do
          expect(passing).not_to receive(:execute)

          allow(passing).to receive(:skip).and_return(Cucumber::Core::Test::Result::Skipped.new)
          test_case.describe_to runner
        end
      end
    end
  end

  context 'with multiple test cases' do
    context 'when the first test case fails' do
      let(:first_test_case) { test_case.with(test_steps: [failing]) }
      let(:last_test_case)  { test_case.with(test_steps: [passing]) }

      it 'reports the results correctly for the following test case' do
        expect(event_bus).to receive(:test_case_finished) { |reported_test_case, result|
          expect(result).to be_failed if reported_test_case.equal?(first_test_case)
          expect(result).to be_passed if reported_test_case.equal?(last_test_case)
        }.twice

        [first_test_case, last_test_case].each do |test_case|
          test_case.describe_to(runner)
        end
      end
    end
  end

  context 'when passing the latest result to a mapping' do
    let(:test_steps) do
      hook_mapping = Cucumber::Core::Test::UnskippableAction.new { |last_result| @result_spy = last_result }
      after_hook = Cucumber::Core::Test::HookStep.new(double, text, double, hook_mapping)
      failing_step = Cucumber::Core::Test::Step.new(double, text, double).with_action { fail }
      [failing_step, after_hook]
    end

    it 'passes a Failed result when the scenario is failing' do
      test_case.describe_to(runner)

      expect(@result_spy).to be_failed
    end
  end

  context 'with around hooks' do
    let(:passing_step) { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { :no_op } }

    it "passes normally when around hooks don't fail" do
      around_hook = Cucumber::Core::Test::AroundHook.new { |block| block.call }
      passing_test_case = test_case.with(test_steps: [passing_step], around_hooks: [around_hook])
      expect(event_bus).to receive(:test_case_finished).with(passing_test_case, anything) do |_reported_test_case, result|
        expect(result).to be_passed
      end
      passing_test_case.describe_to runner
    end

    it 'gets a failed result if the Around hook fails before the test case is run' do
      around_hook = Cucumber::Core::Test::AroundHook.new { |_block| raise exception }
      failing_test_case = test_case.with(test_steps: [passing_step], around_hooks: [around_hook])
      expect(event_bus).to receive(:test_case_finished).with(failing_test_case, anything) do |_reported_test_case, result|
        expect(result).to be_failed
        expect(result.exception).to eq exception
      end
      failing_test_case.describe_to runner
    end

    it 'gets a failed result if the Around hook fails after the test case is run' do
      around_hook = Cucumber::Core::Test::AroundHook.new { |block| block.call; raise exception }
      failing_test_case = test_case.with(test_steps: [passing_step], around_hooks: [around_hook])
      expect(event_bus).to receive(:test_case_finished).with(failing_test_case, anything) do |_reported_test_case, result|
        expect(result).to be_failed
        expect(result.exception).to eq exception
      end
      failing_test_case.describe_to runner
    end

    it 'fails when a step fails if the around hook works' do
      around_hook = Cucumber::Core::Test::AroundHook.new { |block| block.call }
      failing_step = Cucumber::Core::Test::Step.new(double, text, location, location).with_action { raise exception }
      failing_test_case = test_case.with(test_steps: [failing_step], around_hooks: [around_hook])
      expect(event_bus).to receive(:test_case_finished).with(failing_test_case, anything) do |_reported_test_case, result|
        expect(result).to be_failed
        expect(result.exception).to eq exception
      end
      failing_test_case.describe_to runner
    end

    it 'sends after_test_step for a step interrupted by (a timeout in) the around hook' do
      around_hook = Cucumber::Core::Test::AroundHook.new { |block| block.call; raise exception }
      failing_test_case = test_case.with(test_steps: [], around_hooks: [around_hook])
      allow(runner).to receive(:running_test_step).and_return(passing_step)
      expect(event_bus).to receive(:test_step_finished).with(passing_step, anything) do |_reported_test_case, result|
        expect(result).to be_failed
        expect(result.exception).to eq(exception)
      end
      expect(event_bus).to receive(:test_case_finished).with(test_case, anything) do |_reported_test_case, result|
        expect(result).to be_failed
        expect(result.exception).to eq(exception)
      end
      failing_test_case.describe_to(runner)
    end
  end
end
