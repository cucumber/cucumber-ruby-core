# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      class Envelope < Event.new(:envelope)
        attr_reader :envelope
      end
    end
  end
end
