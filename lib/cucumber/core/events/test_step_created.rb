# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a Test::Step was created from a PickleStep
      class TestStepCreated < Event.new(:test_step, :pickle_step)
        # The created test step & source pickle step
      end
    end
  end
end
