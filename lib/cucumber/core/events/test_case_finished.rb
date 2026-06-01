# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a {Test::Case} has finished executing
      class TestCaseFinished < Base
        # @return [Test::Case] that was executed
        attr_reader :test_case

        # @return [Test::Result] the result of running the {Test::Step}
        attr_reader :result

        def self.event_id
          :test_case_finished
        end

        def initialize(test_case, result)
          @test_case = test_case
          @result = result
          super()
        end
      end
    end
  end
end
