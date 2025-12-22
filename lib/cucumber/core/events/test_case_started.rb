# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a {Test::Case} is about to be executed
      class TestCaseStarted < Event.new(:test_case)
        # @return [Test::Case] the test case to be executed
        attr_reader :test_case
      end
    end
  end
end
