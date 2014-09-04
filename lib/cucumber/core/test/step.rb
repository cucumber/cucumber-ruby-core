require 'cucumber/initializer'
require 'cucumber/core/test/result'
require 'cucumber/core/test/mapping'

module Cucumber
  module Core
    module Test
      class Step
        include Cucumber.initializer(:source)
        attr_reader :source

        def initialize(source, mapping = Test::UndefinedMapping.new)
          raise ArgumentError if source.any?(&:nil?)
          @mapping = mapping
          super(source)
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

        def skip(last_result)
          @mapping.skip(last_result)
        end

        def execute(last_result)
          @mapping.execute(last_result)
        end

        def with_mapping(&block)
          self.class.new(source, Test::Mapping.new(&block))
        end

        def name
          source.last.name
        end

        def location
          source.last.location
        end

        def match_locations?(queried_locations)
          return true if queried_locations.include? location
          source.any? { |s| s.match_locations?(queried_locations) } or
          outline_step_match_locations?(queried_locations)
        end

        def inspect
          "<#{self.class}: #{location}>"
        end

        private

        def outline_step_match_locations?(queried_locations)
          source.last.outline_step and 
            source.last.outline_step.match_locations?(queried_locations)
        end

      end
    end
  end
end
