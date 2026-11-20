# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Skipped < Raisable
          def self.ok?
            true
          end

          def describe_to(visitor, *)
            visitor.skipped(*)
            visitor.duration(duration, *)
            self
          end

          def status
            Cucumber::Messages::TestStepResultStatus::SKIPPED
          end

          def to_s
            '-'
          end

          def to_sym
            :skipped
          end
        end
      end
    end
  end
end
