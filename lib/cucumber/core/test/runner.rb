require 'cucumber/initializer'
require 'cucumber/core/test/timer'

module Cucumber
  module Core
    module Test
      class Runner
        class StepRunner
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

          def skipped(step_result)
            @status = Skipping.new
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

          class Skipping
            def execute(test_step, monitor)
              test_step.skip
            end

            def result(duration)
              Result::Skipped.new
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

        attr_reader :report
        private :report
        def initialize(report)
          @report = report
        end

        def test_case(test_case, &descend)
          report.before_test_case(test_case)
          descend.call(self)
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

        def done
          report.done
          self
        end

        private

        def current_case_result
          current_step_runner.result
        end

        def current_step_runner
          @current_step_runner ||= StepRunner.new
        end
      end
    end
  end
end
