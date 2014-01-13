require 'cucumber/initializer'
require 'cucumber/core/test/timer'

module Cucumber
  module Core
    module Test
      class Runner
        module StepRunner
          class Default
            def initialize
              @timer = Timer.new.start
            end

            def execute(test_step)
              status.execute(test_step, self)
            end

            def result
              status.result(@timer.duration)
            end

            def failed(step_result)
              @status = Failing.new(step_result)
              self
            end

            def passed(step_result)
              @status = Passing.new
              self
            end

            def pending(message, step_result)
              @status = Pending.new(step_result)
              self
            end

            def undefined(step_result)
              failed(step_result)
              self
            end

            def exception(step_exception, step_result)
              self
            end

            def duration(step_duration, step_result)
              self
            end

            private

            def status
              @status ||= Unknown.new
            end
          end

          class DryRun
            def execute(test_step)
              step_result = test_step.skip
              @case_result = Result::Undefined.new if step_result.undefined?
              step_result
            end

            def result
              @case_result ||= Result::Skipped.new
            end
          end

          class Unknown
            def execute(test_step, monitor)
              result = test_step.execute
              result.describe_to(monitor, result)
            end

            def result(duration)
              Result::Unknown.new
            end
          end

          class Passing < Unknown
            def result(duration)
              Result::Passed.new(duration)
            end
          end

          Failing = Struct.new(:step_result) do
            def execute(test_step, monitor)
              test_step.skip
            end

            def result(duration)
              step_result.with_duration(duration)
            end
          end

          Pending = Class.new(Failing)
        end

        STEP_RUNNER_STRATEGY = {
          default: StepRunner::Default,
          dry_run: StepRunner::DryRun
        }

        attr_reader :report, :step_runner_class
        private :report, :step_runner_class
        def initialize(report, run_options = {})
          @report = report

          run_mode = run_options.fetch(:run_mode) { :default }
          @step_runner_class = STEP_RUNNER_STRATEGY.fetch(run_mode) do
            raise ArgumentError, "No strategy for run mode: #{run_mode.inspect}"
          end
        end

        def test_case(test_case, &descend)
          report.before_test_case(test_case)
          descend.call
          report.after_test_case(test_case, current_case_result)
          @current_step_runner = nil
        end

        def test_step(test_step)
          report.before_test_step test_step
          step_result = current_step_runner.execute(test_step)
          report.after_test_step test_step, step_result
        end

        def around_hook(hook, &continue)
          hook.call(continue)
        end

        private

        def current_case_result
          current_step_runner.result
        end

        def current_step_runner
          @current_step_runner ||= step_runner_class.new
        end
      end
    end
  end
end
