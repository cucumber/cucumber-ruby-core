# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        # Base class for exceptions that can be raised in a step definition causing the step to have that result.
        class Raisable < StandardError
          attr_reader :message, :duration

          def initialize(message = nil, duration = UnknownDuration.new, backtrace = nil)
            @message = message
            @duration = duration
            super(message)
            set_backtrace(backtrace) if backtrace
          end

          def to_message
            if message
              Cucumber::Messages::TestStepResult.new(
                status: status,
                duration: duration.to_message_duration,
                message: message,
                exception: exception_sub_message
              )
            else
              Cucumber::Messages::TestStepResult.new(
                status: status,
                duration: duration.to_message_duration
              )
            end
          end

          def with_appended_backtrace(step)
            return self unless step.respond_to?(:backtrace_line)

            set_backtrace([]) unless backtrace
            backtrace << step.backtrace_line
            self
          end

          def with_duration(new_duration)
            self.class.new(message, new_duration, backtrace)
          end

          def with_filtered_backtrace(filter)
            return self unless backtrace

            filter.new(dup).exception
          end

          def with_message(new_message)
            self.class.new(new_message, duration, backtrace)
          end

          private

          def exception_sub_message
            Cucumber::Messages::Exception.new(
              type: self.class,
              message: message,
              stack_trace: backtrace&.join("\n")
            )
          end
        end
      end
    end
  end
end
