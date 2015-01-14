module Cucumber
  module Core
    module Test
      class AroundHook
        def initialize(&block)
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
