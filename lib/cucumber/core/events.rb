# frozen_string_literal: true

require_relative 'events/envelope'
require_relative 'events/gherkin_source_parsed'
require_relative 'events/test_case_created'
require_relative 'events/test_case_started'
require_relative 'events/test_case_finished'
require_relative 'events/test_step_created'
require_relative 'events/test_step_started'
require_relative 'events/test_step_finished'

module Cucumber
  module Core
    module Events
      # The registry contains all the events registered in the core, that will be used by the {EventBus} by default.
      def self.registry
        build_registry(
          Envelope,
          GherkinSourceParsed,
          TestCaseCreated,
          TestCaseStarted,
          TestCaseFinished,
          TestStepCreated,
          TestStepStarted,
          TestStepFinished
        )
      end

      # Build an event registry to be passed to the {EventBus} constructor from a list of types.
      # Each type must respond to `event_id` so that it can be added to the registry hash
      #
      # @return [Hash{Symbol => Class}]
      def self.build_registry(*types)
        types.to_h { |type| [type.event_id, type] }
      end
    end
  end
end
