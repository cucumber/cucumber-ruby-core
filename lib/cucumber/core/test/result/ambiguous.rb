# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Ambiguous < Raisable
          def self.ok?
            false
          end

          def describe_to(visitor, *)
            visitor.ambiguous(*)
            visitor.duration(duration, *)
            self
          end

          def status
            Cucumber::Messages::TestStepResultStatus::AMBIGUOUS
          end

          def to_s
            'A'
          end

          def to_sym
            :ambiguous
          end
        end
      end
    end
  end
end
