require 'cucumber/core/test/result'
require 'cucumber/core/test/action'

module Cucumber
  module Core
    module Test
      class Step
        attr_reader :source

        def initialize(source, mapping = Test::UndefinedAction.new)
          raise ArgumentError if source.any?(&:nil?)
          @source = source
          @mapping = mapping
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
          self.class.new(source, Test::Action.new(&block))
        end

        def name
          source.last.name
        end

        def location
          source.last.location
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
