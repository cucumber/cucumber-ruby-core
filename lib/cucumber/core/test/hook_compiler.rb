require 'cucumber/initializer'

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
            compiler.before_hook build_hook_step(block, BeforeHook)
          end

          def after(&block)
            compiler.after_hook build_hook_step(block, AfterHook)
          end

          def around(&block)
            compiler.around_hook AroundHook.new(source, &block)
          end

          private

          def build_hook_step(block, type)
            mapping = Test::Mapping.new(&block)
            hook = type.new(mapping.location)
            Step.new([hook], mapping)
          end
        end

      end

      class BeforeHook
        include Cucumber.initializer(:location)
        public :location

        def name
          "Before hook"
        end

        def match_locations?(queried_locations)
          queried_locations.any? { |other_location| other_location.match?(location) }
        end

        def describe_to(visitor, *args)
          visitor.before_hook(self, *args)
        end
      end

      class AfterHook
        include Cucumber.initializer(:location)
        public :location

        def name
          "After hook"
        end

        def match_locations?(queried_locations)
          queried_locations.any? { |other_location| other_location.match?(location) }
        end

        def describe_to(visitor, *args)
          visitor.after_hook(self, *args)
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
