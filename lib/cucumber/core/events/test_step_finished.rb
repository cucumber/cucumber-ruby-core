# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a {Test::Step} has finished executing
      class TestStepFinished < Event.new(:test_step, :result)
        # @return [Test::Step] the test step that was executed
        attr_reader :test_step

        # @return [Test::Result] the result of running the {Test::Step}
        attr_reader :result
      end
    end
  end
end
