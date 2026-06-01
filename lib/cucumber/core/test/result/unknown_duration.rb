# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class UnknownDuration
          def tap
            self
          end

          def nanoseconds
            raise '#nanoseconds only allowed to be used in #tap block'
          end

          def to_message_duration
            Cucumber::Messages::Duration.new(seconds: 0, nanos: 0)
          end
        end
      end
    end
  end
end
