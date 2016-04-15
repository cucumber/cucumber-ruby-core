module Cucumber
  module Core
    module Report
      class Summary
        attr_reader :test_cases, :test_steps

        def initialize(event_bus)
          @test_cases = Test::Result::Summary.new
          @test_steps = Test::Result::Summary.new
          subscribe_to(event_bus)
        end

        private

        def subscribe_to(events)
          events.on(:test_case_finished) do |test_case, result|
            result.describe_to test_cases
          end
          events.on(:test_step_finished) do |test_step, result|
            result.describe_to test_steps
          end
          self
        end

      end
    end
  end
end
