# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a Test::Case was created from a Pickle
      class TestCaseCreated < Event.new(:test_case, :pickle)
        # The created test step
        attr_reader :test_case

        # The source pickle step
        attr_reader :pickle
      end
    end
  end
end
