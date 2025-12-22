# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a Test::Step was created from a PickleStep
      class TestStepCreated < Event.new(:test_step, :pickle_step)
        # The created test step
        attr_reader :test_step

        # The source pickle step
        attr_reader :pickle_step
      end
    end
  end
end
