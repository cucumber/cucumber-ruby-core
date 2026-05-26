# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Skipped < Raisable
          include Result.query_methods :skipped

          def self.ok?(*)
            true
          end

          def describe_to(visitor, *)
            visitor.skipped(*)
            visitor.duration(duration, *)
            self
          end

          def to_s
            '-'
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::SKIPPED,
              duration: duration.to_message_duration
            )
          end
        end
      end
    end
  end
end
