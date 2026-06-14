# frozen_string_literal: true

require_relative 'base'

module Cucumber
  module Core
    module Events
      class Envelope < Base
        attr_reader :envelope

        # The underscored name of the class to be used as the key in an event registry
        #   @return [Symbol]
        def self.event_id
          :envelope
        end

        def initialize(envelope)
          @envelope = envelope
          super()
        end
      end
    end
  end
end
