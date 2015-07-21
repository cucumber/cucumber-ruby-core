require 'cucumber/core/test/result'
require 'cucumber/core/test/action'

module Cucumber
  module Core
    module Test
      class Step
        attr_reader :source

        def initialize(source, action = Test::UndefinedAction.new(source.last.location), data = {})
          raise ArgumentError if source.any?(&:nil?)
          @source, @action = source, action
          @data = data
        end

        def data(key)
          @data.fetch(key)
        end

        def describe_to(visitor, *args)
          visitor.test_step(self, *args)
        end

        def describe_source_to(visitor, *args)
          source.reverse.each do |node|
            node.describe_to(visitor, *args)
          end
          self
        end

        def skip(*args)
          @action.skip(*args)
        end

        def execute(*args)
          @action.execute(*args)
        end

        def with_action(location = nil, &block)
          self.class.new(source, Test::Action.new(location, &block), @data)
        end

        def with_data(new_data)
          self.class.new(source, @action, @data.merge(new_data))
        end

        def name
          source.last.name
        end

        def location
          source.last.location
        end

        def action_location
          @action.location
        end

        def match_locations?(queried_locations)
          return true if queried_locations.include? location
          source.any? { |s| s.match_locations?(queried_locations) }
        end

        def inspect
          "#<#{self.class}: #{location}>"
        end

      end
    end
  end
end
