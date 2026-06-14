# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        class Duration
          include Cucumber::Messages::Helpers::TimeConversion

          attr_reader :nanoseconds

          def initialize(nanoseconds)
            @nanoseconds = nanoseconds
          end

          def to_message_duration
            duration_hash = seconds_to_duration(nanoseconds.to_f / NANOSECONDS_PER_SECOND)
            Cucumber::Messages::Duration.new(seconds: duration_hash[:seconds], nanos: duration_hash[:nanos])
          end

          def seconds_to_duration(seconds_float)
            seconds, second_modulus = seconds_float.divmod(1)
            nanos = second_modulus * NANOSECONDS_PER_SECOND
            { seconds: seconds, nanos: nanos.to_i }
          end
        end
      end
    end
  end
end
