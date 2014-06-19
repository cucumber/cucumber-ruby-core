require 'cucumber/initializer'

module Cucumber
  module Core
    module Test

      # Sits in the filter chain and adds hooks onto test cases
      class HookCompiler
        include Cucumber.initializer(:user_mappings, :receiver)

        def done
          receiver.done
          self
        end

        def test_case(test_case, &descend)
          @before_hooks, @after_hooks, @around_hooks, @test_steps = [], [], [], []
          mapper = CaseHookMapperDSL.new(self)
          test_case.describe_to user_mappings, mapper
          descend.call
          test_case.
            with_steps(@before_hooks + @test_steps + @after_hooks).
            with_around_hooks(@around_hooks).
            describe_to(receiver)
          self
        end

        def test_step(test_step)
          @test_steps << test_step
          mapper = StepHookMapperDSL.new(self)
          test_step.describe_to user_mappings, mapper
          self
        end

        def before_hook(block)
          @before_hooks << hook_factory.before(block)
          self
        end

        def after_hook(block)
          @after_hooks << hook_factory.after(block)
          self
        end

        def around_hook(hook)
          @around_hooks << hook
          self
        end

        def after_step_hook(block)
          @test_steps << hook_factory.after_step(block)
          self
        end

        private

        def hook_factory
          @hook_factory ||= HookFactory.new
        end

        class HookFactory
          def after(block)
            build_hook_step(block, AfterHook, Test::UnskippableMapping)
          end

          def before(block)
            build_hook_step(block, BeforeHook, Test::UnskippableMapping)
          end

          def after_step(block)
            build_hook_step(block, AfterStepHook, Test::Mapping)
          end

          private

          def build_hook_step(block, hook_type, mapping_type)
            mapping = mapping_type.new(&block)
            hook = hook_type.new(mapping.location)
            Step.new([hook], mapping)
          end

        end

        # This is the object yielded to users (in the mappings) when defining hooks for a test case
        class CaseHookMapperDSL
          include Cucumber.initializer(:compiler)

          def before(&block)
            compiler.before_hook block
          end

          def after(&block)
            compiler.after_hook block
          end

          def around(&block)
            compiler.around_hook AroundHook.new(&block)
          end
        end

        # Yielded to users in the mappings when defining hooks for a test step
        class StepHookMapperDSL
          include Cucumber.initializer(:compiler)

          def after(&block)
            compiler.after_step_hook block
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

      class AfterStepHook
        include Cucumber.initializer(:location)
        public :location

        def name
          "AfterStep hook"
        end

        def match_locations?(queried_locations)
          queried_locations.any? { |other_location| other_location.match?(location) }
        end

        def describe_to(visitor, *args)
          visitor.after_step_hook(self, *args)
        end
      end

    end
  end
end
