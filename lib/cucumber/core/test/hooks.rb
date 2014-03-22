require 'cucumber/initializer'
require 'cucumber/core/test/mapping'

module Cucumber
  module Core
    module Test
      class HookStep
        include Cucumber.initializer(:source)

        def initialize(source, mapping)
          @mapping = mapping
          @source = source
        end

        def describe_to(visitor, *args)
          visitor.test_step(self, *args)
        end

        def describe_source_to(visitor, *args)
          @source.each do |node|
            node.describe_to(visitor, *args)
          end
        end

        def execute
          @mapping.execute
        end

        def skip
          execute
        end

        def match_locations?(locations)
          false
        end

        def inspect
          "<#{self.class}: #{@mapping.location}>"
        end
      end

      class AroundHook
        def initialize(source, &block)
          @source = source
          @block = block
        end

        def describe_to(visitor, *args, &continue)
          visitor.around_hook(self, *args, &continue)
        end

        def call(continue)
          @block.call(continue)
        end
      end
    end
  end
end
