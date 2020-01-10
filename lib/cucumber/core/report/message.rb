# frozen_string_literal: true
module Cucumber
  module Core
    module Report
      class Message
        def initialize(event_bus)
          @pickle_step_by_step_id = {}
          @pickle_by_test_case_id = {}
          subscribe_to(event_bus)
        end

        private

        def subscribe_to(event_bus)
          event_bus.on(:test_step_created) do |event|
            @pickle_step_by_step_id[event.test_step.id] = event.pickle_step
          end

          event_bus.on(:test_case_created) do |event|
            @pickle_by_test_case_id[event.test_case.id] = event.pickle
          end

          event_bus.on(:test_run_started) do |event|
            puts "Know pickles and steps"
            puts "Pickles:"
            puts  @pickle_by_test_case_id.map {|id, pickle| " - #{id} - #{pickle}"}.join("\n")

            puts "Pickle steps:"
            puts  @pickle_step_by_step_id.map {|id, pickle_step| " - #{id} - #{pickle_step}"}.join("\n")

          end
        end
      end
    end
  end
end
