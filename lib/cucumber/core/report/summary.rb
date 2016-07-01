# frozen_string_literal: true
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

        def subscribe_to(event_bus)
          event_bus.on(:test_case_finished) do |event|
            event.result.describe_to test_cases
          end
          event_bus.on(:test_step_finished) do |event|
            event.result.describe_to test_steps if is_step?(event.test_step)
          end
          self
        end

        def is_step?(test_step)
          StepQueryVisitor.new(test_step).is_step?
        end
      end

      class StepQueryVisitor
        def initialize(test_step)
          @step = false
          test_step.source.last.describe_to(self)
        end

        def is_step?
          @step
        end

        def step(*)
          @step = true
        end
        
        def method_missing(*)
        end
      end
    end
  end
end
