# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a {Test::Step} is about to be executed
      class TestStepStarted < Event.new(:test_step)
        # @return [Test::Step] the test step to be executed
        attr_reader :test_step
      end
    end
  end
end
