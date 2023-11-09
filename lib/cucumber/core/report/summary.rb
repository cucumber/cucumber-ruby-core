# frozen_string_literal: true

require 'set'

module Cucumber
  module Core
    module Report
      class Summary
        attr_reader :test_cases, :test_steps

        def initialize(event_bus)
          @previous_test_cases = Set.new
          @test_cases = Test::Result::Summary.new
          @test_steps = Test::Result::Summary.new
          subscribe_to(event_bus)
        end

        def ok?(strict: Test::Result::StrictConfiguration.new)
          test_cases.ok?(strict: strict)
        end

        private

        def subscribe_to(event_bus)
          register_test_case_finished_listener(event_bus)
          register_test_step_finished_listener(event_bus)
          self
        end

        def register_test_case_finished_listener(event_bus)
          event_bus.on(:test_case_finished) do |event|
            if !@previous_test_cases.include?(event.test_case)
              @previous_test_cases << event.test_case
              event.result.describe_to(test_cases)
            elsif event.result.passed? || event.result.skipped?
              test_cases.flaky
              test_cases.decrement_failed
            end
          end
        end

        def register_test_step_finished_listener(event_bus)
          event_bus.on(:test_step_finished) do |event|
            event.result.describe_to(test_steps) unless event.test_step.hook?
          end
        end
      end
    end
  end
end
