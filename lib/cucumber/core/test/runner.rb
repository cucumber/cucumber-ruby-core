# frozen_string_literal: true

require_relative 'timer'
require 'cucumber/messages'

module Cucumber
  module Core
    module Test
      class Runner
        include Cucumber::Messages::Helpers::TimeConversion

        attr_reader :event_bus, :running_test_case, :running_test_step, :id_generator
        private :event_bus, :running_test_case, :running_test_step, :id_generator

        def initialize(event_bus, max_attempts = 1)
          @event_bus = event_bus
          @max_attempts = max_attempts
          @id_generator = Cucumber::Messages::Helpers::IdGenerator::UUID.new
          @current_test_case = nil
        end

        def test_case(test_case, &descend)
          if @current_test_case == test_case
            @attempt += 1
          else
            @attempt = 1
          end
          @current_test_case = test_case
          @current_test_case_started_id = id_generator.new_id
          @running_test_case = RunningTestCase.new
          @running_test_step = nil
          event_bus.test_case_started(test_case)
          message = Cucumber::Messages::Envelope.new(
            test_case_started: Cucumber::Messages::TestCaseStarted.new(
              id: @current_test_case_started_id,
              test_case_id: test_case.id,
              timestamp: time_to_timestamp(Time.now),
              attempt: @attempt
            )
          )
          event_bus.envelope(message)

          descend.call(self)
          result = running_test_case.result
          result = Result::Undefined.new('The test case has no steps', Result::UnknownDuration.new, ["#{test_case.location}:in `#{test_case.name}'"]) if result.unknown?

          event_bus.test_case_finished(test_case, result)
          will_be_retried = result.failed? && (@attempt < @max_attempts)
          message = Cucumber::Messages::Envelope.new(
            test_case_finished: Cucumber::Messages::TestCaseFinished.new(
              test_case_started_id: @current_test_case_started_id,
              timestamp: time_to_timestamp(Time.now),
              will_be_retried: will_be_retried
            )
          )
          event_bus.envelope(message)
          self
        end

        def test_step(test_step)
          @running_test_step = test_step
          event_bus.test_step_started test_step
          step_result = running_test_case.execute(test_step)
          event_bus.test_step_finished test_step, step_result
          @running_test_step = nil
          self
        end

        def around_hook(hook, &)
          result = running_test_case.execute(hook, &)
          event_bus.test_step_finished running_test_step, result if running_test_step
          @running_test_step = nil
          self
        end

        def done
          self
        end

        class RunningTestCase
          def initialize
            @timer = Timer.new.start
            @status = Status::Unknown.new(Result::Unknown.new)
          end

          def execute(test_step, &)
            status.execute(test_step, self, &)
          end

          def result
            status.result(@timer.duration)
          end

          def failed(step_result)
            @status = Status::Failing.new(step_result)
            self
          end

          def ambiguous(step_result)
            @status = Status::Ambiguous.new(step_result)
            self
          end

          def passed(step_result)
            @status = Status::Passing.new(step_result)
            self
          end

          def pending(_message, step_result)
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

          def exception(_step_exception, _step_result)
            self
          end

          def duration(_step_duration, _step_result)
            self
          end

          attr_reader :status
          private :status

          module Status
            class Base
              attr_reader :step_result
              private :step_result

              def initialize(step_result)
                @step_result = step_result
              end

              def execute(test_step, monitor, &)
                result = test_step.execute(monitor.result, &)
                result = result.with_message(%(Undefined step: "#{test_step.text}")) if result.undefined?
                result = result.with_appended_backtrace(test_step) unless test_step.hook?
                result.describe_to(monitor, result)
              end

              def result
                raise NoMethodError, 'Override me'
              end
            end

            class Unknown < Base
              def result(_duration)
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
                result = test_step.skip(monitor.result)
                if result.undefined?
                  result = result.with_message(%(Undefined step: "#{test_step.text}"))
                  result = result.with_appended_backtrace(test_step)
                end
                result
              end

              def result(duration)
                step_result.with_duration(duration)
              end
            end

            Pending = Class.new(Failing)

            Ambiguous = Class.new(Failing)

            class Skipping < Failing
              def result(duration)
                step_result.with_duration(duration)
              end
            end
          end
        end
      end
    end
  end
end
