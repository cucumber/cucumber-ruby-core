# frozen_string_literal: true

require 'cucumber/messages/helpers/test_step_result_comparator'

require_relative 'timer'
require 'cucumber/messages'

module Cucumber
  module Core
    module Test
      class Runner
        include Cucumber::Messages::Helpers::TimeConversion

        attr_reader :event_bus, :running_test_case, :running_test_step, :id_generator
        private :event_bus, :running_test_case, :running_test_step, :id_generator

        def initialize(event_bus, id_generator = Cucumber::Messages::Helpers::IdGenerator::UUID.new, backtrace_filter = nil, max_attempts = 1)
          @event_bus = event_bus
          @id_generator = id_generator
          @backtrace_filter = backtrace_filter
          @max_attempts = max_attempts
          @current_test_case = nil
        end

        def test_case(test_case, &descend)
          @attempt = @current_test_case == test_case ? @attempt + 1 : 1
          @current_test_case = test_case
          @current_test_case_started_id = id_generator.new_id
          @running_test_case = RunningTestCase.new
          @running_test_step = nil
          event_bus.test_case_started(test_case)
          event_bus.envelope(to_test_case_started_envelope(test_case))

          descend.call(self)

          result = calculate_test_case_result(test_case)
          event_bus.test_case_finished(test_case, result)
          event_bus.envelope(to_test_case_finished_envelope(result))
          self
        end

        def test_step(test_step)
          @running_test_step = test_step
          event_bus.test_step_started test_step
          event_bus.envelope(to_test_step_started_envelope(test_step))

          step_result = running_test_case.execute(test_step)

          event_bus.test_step_finished test_step, step_result
          event_bus.envelope(to_test_step_finished_envelope(test_step, step_result))
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

        def calculate_test_case_result(test_case)
          if running_test_case.result.unknown?
            Result::Undefined.new('The test case has no steps', Result::UnknownDuration.new, ["#{test_case.location}:in `#{test_case.name}'"])
          else
            running_test_case.result
          end
        end

        def to_test_case_started_envelope(test_case)
          Cucumber::Messages::Envelope.new(
            test_case_started: Cucumber::Messages::TestCaseStarted.new(
              id: @current_test_case_started_id,
              test_case_id: test_case.id,
              timestamp: time_to_timestamp(Time.now),
              attempt: @attempt
            )
          )
        end

        def to_test_case_finished_envelope(result)
          Cucumber::Messages::Envelope.new(
            test_case_finished: Cucumber::Messages::TestCaseFinished.new(
              test_case_started_id: @current_test_case_started_id,
              timestamp: time_to_timestamp(Time.now),
              will_be_retried: result.failed? && (@attempt < @max_attempts)
            )
          )
        end

        def to_test_step_started_envelope(test_step)
          Cucumber::Messages::Envelope.new(
            test_step_started: Cucumber::Messages::TestStepStarted.new(
              test_step_id: test_step.id,
              test_case_started_id: @current_test_case_started_id,
              timestamp: time_to_timestamp(Time.now)
            )
          )
        end

        def to_test_step_finished_envelope(test_step, step_result)
          result = @backtrace_filter.nil? ? step_result : step_result.with_filtered_backtrace(@backtrace_filter)
          result_message = result.to_message
          if result.failed? || result.pending?
            message_element = result.failed? ? result.exception : result

            result_message = Cucumber::Messages::TestStepResult.new(
              status: result_message.status,
              duration: result_message.duration,
              message: to_error_message(message_element),
              exception: to_exception_object(result, message_element)
            )
          end
          Cucumber::Messages::Envelope.new(
            test_step_finished: Cucumber::Messages::TestStepFinished.new(
              test_step_id: test_step.id,
              test_case_started_id: @current_test_case_started_id,
              test_step_result: result_message,
              timestamp: time_to_timestamp(Time.now)
            )
          )
        end

        def to_error_message(message_element)
          <<~ERROR_MESSAGE
            #{message_element.message} (#{message_element.class})
            #{message_element.backtrace}
          ERROR_MESSAGE
        end

        def to_exception_object(result, message_element)
          return unless result.failed?

          Cucumber::Messages::Exception.new(
            type: message_element.class,
            message: message_element.message,
            stack_trace: message_element.backtrace.join("\n")
          )
        end

        class RunningTestCase
          include Cucumber::Messages::Helpers::TestStepResultComparator

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
            not_passing(step_result)
            self
          end

          def ambiguous(step_result)
            failed(step_result)
            self
          end

          def passed(step_result)
            @status = Status::Passing.new(step_result) if test_step_result_rankings[step_result.to_message.status] > test_step_result_rankings[status.step_result_message.status]
            self
          end

          def pending(_message, step_result)
            failed(step_result)
            self
          end

          def skipped(step_result)
            failed(step_result)
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

          private

          def not_passing(step_result)
            @status = Status::NotPassing.new(step_result) if test_step_result_rankings[step_result.to_message.status] > test_step_result_rankings[status.step_result_message.status]
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

              def step_result_message
                step_result.to_message
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

            class NotPassing < Base
              def execute(test_step, monitor)
                result = test_step.skip(monitor.result)
                result = result.with_message(%(Undefined step: "#{test_step.text}")) if result.undefined?
                result = result.with_appended_backtrace(test_step) unless test_step.hook?
                result.describe_to(monitor, result)
              end

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
