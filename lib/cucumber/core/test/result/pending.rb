# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Pending < Raisable
          def self.ok?
            false
          end

          def describe_to(visitor, *)
            visitor.pending(self, *)
            visitor.duration(duration, *)
            self
          end

          def status
            Cucumber::Messages::TestStepResultStatus::PENDING
          end

          def to_s
            'P'
          end

          def to_sym
            :pending
          end
        end
      end
    end
  end
end
