require 'cucumber/initializer'
require 'cucumber/core/test/hooks'

module Cucumber
  module Core
    module Test

      # Sits in the filter chain and adds hooks onto test cases
      class HookCompiler
        include Cucumber.initializer(:mappings, :receiver)

        def done
          receiver.done
          self
        end

        def test_case(test_case, &descend)
          @before_hooks, @after_hooks, @around_hooks, @steps = [], [], [], []
          mapper = HookMapperDSL.new(self, test_case.source)
          test_case.describe_to mappings, mapper
          descend.call
          test_case.
            with_steps(@before_hooks + @steps + @after_hooks).
            with_around_hooks(@around_hooks).
            describe_to(receiver)
        end

        def before_hook(hook)
          @before_hooks << hook
        end

        def after_hook(hook)
          @after_hooks << hook
        end

        def around_hook(hook)
          @around_hooks << hook
        end

        def test_step(step)
          @steps << step
        end

        # This is the object yielded to users (in the mappings) when defining hooks
        class HookMapperDSL
          include Cucumber.initializer(:compiler, :source)

          def before(&block)
            compiler.before_hook BeforeHook.new(source, &block)
          end

          def after(&block)
            compiler.after_hook AfterHook.new(source, &block)
          end

          def around(&block)
            compiler.around_hook AroundHook.new(source, &block)
          end
        end

      end
    end
  end
end
