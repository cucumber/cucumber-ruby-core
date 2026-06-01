# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      class Envelope < Event.new(:envelope)
      end
    end
  end
end
