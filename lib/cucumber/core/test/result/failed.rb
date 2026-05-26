# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Failed
          include BooleanMethods

          attr_reader :duration, :exception

          def self.ok?
            false
          end

          def initialize(duration, exception)
            raise ArgumentError unless duration
            raise ArgumentError unless exception

            @duration = duration
            @exception = exception
          end

          def describe_to(visitor, *)
            visitor.failed(*)
            visitor.duration(duration, *)
            visitor.exception(exception, *) if exception
            self
          end

          def to_s
            '✗'
          end

          def to_sym
            :failed
          end

          def to_message
            begin
              message = exception.backtrace.join("\n")
            rescue NoMethodError
              message = ''
            end

            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::FAILED,
              duration: duration.to_message_duration,
              message: message
            )
          end

          def with_duration(new_duration)
            self.class.new(new_duration, exception)
          end

          def with_appended_backtrace(step)
            exception.backtrace << step.backtrace_line if step.respond_to?(:backtrace_line)
            self
          end

          def with_filtered_backtrace(filter)
            self.class.new(duration, filter.new(exception.dup).exception)
          end
        end
      end
    end
  end
end
