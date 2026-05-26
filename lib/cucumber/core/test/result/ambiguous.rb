# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Ambiguous < Raisable
          include Result.query_methods :ambiguous

          def self.ok?(*)
            false
          end

          def describe_to(visitor, *)
            visitor.ambiguous(*)
            visitor.duration(duration, *)
            self
          end

          def to_s
            'A'
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::AMBIGUOUS,
              duration: duration.to_message_duration
            )
          end
        end
      end
    end
  end
end
