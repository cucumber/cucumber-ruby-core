require 'cucumber/core/test/mapping'
module Cucumber
  module Core
    module Test
      class HookStep
        def initialize(source, &block)
          @mapping = Test::Mapping.new(&block)
          @source = source
        end

        def describe_to(visitor, *args)
          visitor.test_step(self, *args)
        end

        def describe_source_to(visitor, *args)
          visitor.hook(*args)
        end

        def execute
          @mapping.execute
        end

        def skip
          execute
        end

        def map
          self
        end

        def match_locations?(locations)
          false
        end

        def inspect
          "<#{self.class}: #{@mapping.location}>"
        end
      end
    end
  end
end
