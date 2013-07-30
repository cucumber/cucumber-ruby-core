require 'cucumber/initializer'
require 'cucumber/core/test/timer'

module Cucumber
  module Core
    module Test
      class Runner
        include Cucumber.initializer(:report)

        def test_case(test_case, &descend)
          report.before_test_case(test_case)
          descend.call
          report.after_test_case(test_case, current_case_result)
          @current_case_status = nil
        end

        def test_step(test_step)
          report.before_test_step test_step
          step_result = current_case_status.execute(test_step)
          report.after_test_step test_step, step_result
        end

        private

        def current_case_result
          current_case_status.result
        end

        def current_case_status
          @current_case_status ||= Status::Monitor.new
        end

        module Status
          class Monitor
            def initialize
              @timer = Timer.new
              @timer.start
            end

            def execute(test_step)
              status.execute(test_step, self)
            end

            def result
              status.result
            end

            def failed(result)
              @status = Failing.new(@timer, result.exception)
            end

            def passed(result)
              @status = Passing.new(@timer)
            end

            def undefined(result)
              failed
            end

            def exception(exception, result)
            end

            def duration(*)
            end

            private

            def status
              @status ||= Unknown.new
            end
          end

          class Unknown
            def execute(test_step, monitor)
              result = test_step.execute
              result.describe_to(monitor, result)
            end

            def result
              Result::Unknown.new
            end
          end

          class Passing < Unknown
            def initialize(timer)
              @timer = timer
            end

            def result
              Result::Passed.new(@timer.duration)
            end
          end

          Failing = Struct.new(:timer, :exception) do
            def execute(test_step, monitor)
              test_step.skip
            end

            def result
              Result::Failed.new(timer.duration, exception)
            end
          end
        end

      end
    end
  end
end
