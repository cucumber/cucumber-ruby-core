require 'cucumber/initializer'

module Cucumber
  module Core
    module Test
      class HookStep
        def initialize(&block)
          @mapping = Test::Mapping.new(&block)
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
          @mapping.skip
        end

        def map
          self
        end

        def match_locations?(locations)
          false
        end

        def inspect
          "#{self.class}"
        end
      end

      class HookCompiler
        include Cucumber.initializer(:mappings, :receiver)

        def test_case(test_case, &descend)
          @before_hooks, @after_hooks, @steps = [], [], []
          mapper = HookMapper.new(self)
          test_case.describe_to mappings, mapper
          descend.call
          test_case.
            with_steps(@before_hooks + @steps + @after_hooks).
            describe_to(receiver)
        end

        def before_hook(hook)
          @before_hooks << hook
        end

        def after_hook(hook)
          @after_hooks << hook
        end

        def test_step(step)
          @steps << step
        end

        class HookMapper
          include Cucumber.initializer(:compiler)

          def before(&block)
            compiler.before_hook HookStep.new(&block)
          end

          def after(&block)
            compiler.after_hook HookStep.new(&block)
          end
        end
      end
    end
  end
end
