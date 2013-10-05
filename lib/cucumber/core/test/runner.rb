require 'cucumber/initializer'
require 'cucumber/core/test/timer'

module Cucumber
  module Core
    module Test
      class Runner
        module Status
          class DefaultMonitor
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

          class DryRunMonitor
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

        def self.new(status_monitor)
          Class.new do

            class << self
              attr_accessor :status_monitor_class
              private :status_monitor_class=
            end

            self.status_monitor_class = status_monitor

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
              @current_case_status ||= new_status_monitor
            end

            def new_status_monitor
              self.class.status_monitor_class.new
            end
          end
        end

        Test::DefaultRunner = new(Status::DefaultMonitor)
        Test::DryRunRunner = new(Status::DryRunMonitor)

        TEST_RUNNER_LIST = {
          default: DefaultRunner,
          dry_run: DryRunRunner
        }

        def self.runner_from(run_mode, report)
          test_runner_class = TEST_RUNNER_LIST.fetch(run_mode) do
            raise ArgumentError, "No known Test Runner for run_mode: #{run_mode.inspect}."
          end
          test_runner_class.new(report)
        end

      end

    end
  end
end
