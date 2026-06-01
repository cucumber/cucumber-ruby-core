# frozen_string_literal: true

require_relative 'base'

module Cucumber
  module Core
    module Events
      # Signals that a Test::Case was created from a Pickle
      class TestCaseCreated < Base
        attr_reader :test_case, :pickle

        def self.event_id
          :test_case_created
        end

        def initialize(test_case, pickle)
          @test_case = test_case
          @pickle = pickle
          super()
        end
      end
    end
  end
end
