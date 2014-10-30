require 'cucumber/initializer'
require 'cucumber/core/test/result'
require 'cucumber/core/test/action'

module Cucumber
  module Core
    module Test
      class Step
        include Cucumber.initializer(:source)
        attr_reader :source

        def initialize(source, mapping = Test::UndefinedAction.new)
          @mapping = mapping
          super(source)
        end

        def describe_to(visitor, *args)
          visitor.test_step(self, *args)
        end

        def describe_source_to(visitor, *args)
          source.describe_to(visitor, *args)
          self
        end

        def skip(last_result)
          @mapping.skip(last_result)
        end

        def execute(last_result)
          @mapping.execute(last_result)
        end

        def with_mapping(&block)
          self.class.new(source, Test::Action.new(&block))
        end

        def name
          source.step.name
        end

        def location
          source.step.location
        end

        def match_locations?(queried_locations)
          return true if queried_locations.include? location
          source.any? { |s| s.match_locations?(queried_locations) }
        end

        def inspect
          "<#{self.class}: #{location}>"
        end

      end
    end
  end
end
