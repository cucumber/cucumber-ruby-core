require 'cucumber/initializer'

module Cucumber
  module Core
    module Test
      class Runner
        include Cucumber.initializer(:report)

        def test_case(test_case, &descend)
          case_runner = CaseRunner.new(report)
          report.before_test_case(test_case)
          descend.call(case_runner)
          report.after_test_case(test_case, case_runner.result)
        end

        private

        class CaseRunner
          include Cucumber.initializer(:report)

          def test_step(test_step)
            report.before_test_step test_step
            result = status.execute(test_step)
            report.after_test_step test_step, result
          end

          def result
            status.result
          end

          def status
            @status ||= Status::Monitor.new
          end

          module Status
            class Monitor
              def execute(test_step)
                status.execute(test_step, self)
              end

              def result
                status.result
              end

              def failed
                @status = Status::Failed.new
              end

              def exception(exception)
              end

              def undefined
                failed
              end

              def passed
                @status = Status::Passing.new
              end

              def skipped
              end

              def duration(*)
              end

              private

              def status
                @status ||= Status::Unknown.new
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
end
