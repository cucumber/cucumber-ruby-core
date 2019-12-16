# frozen_string_literal: true
require 'securerandom'

require 'cucumber/messages'
require 'cucumber/core/test/result'
require 'cucumber/core/test/action'
require 'cucumber/core/test/empty_multiline_argument'

module Cucumber
  module Core
    module Test
      class Step
        attr_reader :id, :text, :location, :multiline_arg

        def initialize(id, pickle_step_id, text, location, multiline_arg, action)
          raise ArgumentError if text.nil? || text.empty?
          @id = id
          @pickle_step_id = pickle_step_id
          @text = text
          @location = location
          @multiline_arg = multiline_arg || Test::EmptyMultilineArgument.new
          @action = action || Test::UndefinedAction.new(location)
        end

        def describe_to(visitor, *args)
          visitor.test_step(self, *args)
        end

        def hook?
          false
        end

        def to_message
          Cucumber::Messages::TestCase::TestStep.new(
            id: @id,
            pickle_step_id: @pickle_step_id
          )
        end

        def skip(*args)
          @action.skip(*args)
        end

        def execute(*args)
          @action.execute(*args)
        end

        def with_action(action_location = nil, &block)
          self.class.new(
            @id,
            @pickle_step_id,
            text,
            location,
            multiline_arg,
            Test::Action.new(action_location, &block)
          )
        end

        def backtrace_line
          "#{location}:in `#{text}'"
        end

        def to_s
          text
        end

        def action_location
          @action.location
        end

        def inspect
          "#<#{self.class}: #{location}>"
        end
      end

      class HookStep < Step
        def initialize(id, hook_id, text, location, action)
          super(id, nil, text, location, Test::EmptyMultilineArgument.new, action)
          @hook_id = hook_id
        end

        def hook?
          true
        end

        def to_message
          Cucumber::Messages::TestCase::TestStep.new(
            id: @id,
            hookId: @hook_id
          )
        end
      end
    end
  end
end
