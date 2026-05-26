# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        # Null object for results. Represents the state where we haven't run anything yet
        class Unknown
          include BooleanMethods

          def describe_to(_visitor, *_args)
            self
          end

          def with_filtered_backtrace(_filter)
            self
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::UNKNOWN,
              duration: UnknownDuration.new.to_message_duration
            )
          end

          def to_sym
            :unknown
          end
        end
      end
    end
  end
end
