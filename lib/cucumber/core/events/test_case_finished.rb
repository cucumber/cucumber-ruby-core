# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a {Test::Case} has finished executing
      class TestCaseFinished < Event.new(:test_case, :result)
        # @return [Test::Case] that was executed
        attr_reader :test_case

        # @return [Test::Result] the result of running the {Test::Step}
        attr_reader :result
      end
    end
  end
end
