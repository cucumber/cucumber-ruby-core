# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a {Test::Step} has finished executing
      class TestStepFinished < Event.new(:test_step, :result)
        # @return [Test::Step] the test step that was executed
        # @return [Test::Result] the result of running the {Test::Step}
      end
    end
  end
end
