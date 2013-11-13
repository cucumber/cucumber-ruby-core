require 'cucumber/initializer'

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
          "#{self.class}"
        end
      end

      class HookCompiler
        include Cucumber.initializer(:mappings, :receiver)

        def test_case(test_case, &descend)
          @before_hooks, @after_hooks, @around_hooks, @steps = [], [], [], []
          mapper = HookMapper.new(self, test_case.source)
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

        class HookMapper
          include Cucumber.initializer(:compiler, :source)

          def before(&block)
            compiler.before_hook HookStep.new(source, &block)
          end

          def after(&block)
            compiler.after_hook HookStep.new(source, &block)
          end

          def around(&block)
            compiler.around_hook AroundHook.new(source, &block)
          end

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
  end
end
