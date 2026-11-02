# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Failed < Raisable
          def self.ok?
            false
          end

          def describe_to(visitor, *)
            visitor.failed(*)
            visitor.duration(duration, *)
            visitor.exception(exception_sub_message.type, *)
            # visitor.message(message, *) if message
            # visitor.backtrace(backtrace, *)
            self
          end

          def status
            Cucumber::Messages::TestStepResultStatus::FAILED
          end

          def to_s
            '✗'
          end

          def to_sym
            :failed
          end
        end
      end
    end
  end
end
