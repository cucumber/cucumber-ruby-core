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

      BeforeHook = Class.new(HookStep)
      AfterHook = Class.new(HookStep)

      class AroundHook
        def initialize(source, &block)
          @source = source
          @block = block
        end

        def call(continue)
          @block.call(continue)
        end

        def describe_to(visitor, *args, &continue)
          visitor.around_hook(self, *args, &continue)
        end
      end
    end
  end
end
