require 'cucumber/core/events/bus'
require 'cucumber/core/events/event'

module Cucumber
  module Core
    module Events
      TestCaseStarting = Event.new(:test_case)
      TestStepStarting = Event.new(:test_step)
      TestStepFinished = Event.new(:test_step, :result)
      TestCaseFinished = Event.new(:test_case, :result)

      def self.registry
        build_registry(
          TestCaseStarting,
          TestStepStarting,
          TestStepFinished,
          TestCaseFinished,
        )
      end

      def self.build_registry(*types)
        types.map { |type| [type.event_id, type] }.to_h
      end
    end
  end
end
