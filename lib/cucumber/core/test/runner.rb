require 'cucumber/initializer'

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
          @current_case_status ||= CaseStatus::Monitor.new
        end

        module CaseStatus
          class Monitor
            def execute(test_step)
              status.execute(test_step, self)
            end

            def result
              status.result
            end

            def failed
              @status = Failed.new
            end

            def passed
              @status = Passing.new
            end

            def undefined
              failed
            end

            def exception(exception)
            end

            def skipped
            end

            def duration(*)
            end

            private

            def status
              @status ||= Unknown.new
            end
          end

          Unknown = Class.new do
            def execute(test_step, monitor)
              test_step.execute.describe_to(monitor)
            end

            def result
              Result::Unknown.new
            end
          end

          Passing = Class.new(Unknown) do
            def result
              Result::Passed.new
            end
          end

          Failed = Class.new do
            def execute(test_step, monitor)
              test_step.skip
            end

            def result
              Result::Failed.new
            end
          end
        end

      end
    end
  end
end
