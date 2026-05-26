# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Passed
          include Result.query_methods :passed

          attr_accessor :duration

          def self.ok?(*)
            true
          end

          def initialize(duration)
            raise ArgumentError unless duration

            @duration = duration
          end

          def describe_to(visitor, *)
            visitor.passed(*)
            visitor.duration(duration, *)
            self
          end

          def to_s
            '✓'
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::PASSED,
              duration: duration.to_message_duration
            )
          end

          def ok?(*)
            self.class.ok?
          end

          def with_appended_backtrace(_step)
            self
          end

          def with_filtered_backtrace(_filter)
            self
          end
        end
      end
    end
  end
end
