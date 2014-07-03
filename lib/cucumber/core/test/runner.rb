require 'cucumber/initializer'
require 'cucumber/core/test/timer'

module Cucumber
  module Core
    module Test
      class Runner
        class StepRunner
          def initialize
            @timer = Timer.new.start
            @status = Status::Unknown.new(Result::Unknown.new)
          end

          def execute(test_step)
            status.execute(test_step, self)
          end

          def result
            status.result(@timer.duration)
          end

          def failed(step_result)
            @status = Status::Failing.new(step_result)
            self
          end

          def passed(step_result)
            @status = Status::Passing.new(step_result)
            self
          end

          def pending(message, step_result)
            @status = Status::Pending.new(step_result)
            self
          end

          def skipped(step_result)
            @status = Status::Skipping.new(step_result)
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

          attr_reader :status
          private :status

          module Status
            class Base
              include Cucumber.initializer(:step_result)

              def execute(test_step, monitor)
                result = test_step.execute
                result.describe_to(monitor, result)
              end

              def result
                raise NoMethodError, "Override me"
              end
            end

            class Unknown < Base
              def result(duration)
                Result::Unknown.new
              end
            end

            class Passing < Base
              def result(duration)
                Result::Passed.new(duration)
              end
            end

            class Failing < Base
              def execute(test_step, monitor)
                test_step.skip
              end

              def result(duration)
                step_result.with_duration(duration)
              end
            end

            Pending = Class.new(Failing)

            class Skipping < Failing
              def result(duration)
                step_result.with_duration(duration)
              end
            end
          end
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
