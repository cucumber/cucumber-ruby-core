require 'cucumber/core/test/hooks'

module Cucumber
  module Core
    module Test
      class Mapper
        attr_reader :mapping_definition, :receiver
        private     :mapping_definition, :receiver

        def initialize(mapping_definition, receiver=nil)
          @mapping_definition = mapping_definition
          @receiver           = receiver
        end

        def test_case(test_case, &descend)
          hook_factory = HookFactory.new(test_case.source)
          mapper = CaseMapper.new(mapping_definition)
          test_case.describe_to mapping_definition, CaseMapper::DSL.new(mapper, hook_factory)
          descend.call(mapper)
          test_case.
            with_steps(mapper.before_hooks + mapper.test_steps + mapper.after_hooks).
            with_around_hooks(mapper.around_hooks).
            describe_to(receiver)
          self
        end

        def done
          receiver.done
          self
        end

        def with_receiver(receiver)
          self.class.new(mapping_definition, receiver)
        end

        private

        class CaseMapper
          attr_reader :mapping_definition
          private     :mapping_definition

          def initialize(mapping_definition)
            @mapping_definition = mapping_definition
          end

          def test_step(test_step)
            hook_factory = HookFactory.new(test_step.source)
            mapper = StepMapper.new(test_step)
            test_step.describe_to mapping_definition, StepMapper::DSL.new(mapper, hook_factory)
            test_steps.push(*(mapper.before_step_hooks + [mapper.test_step] + mapper.after_step_hooks))
            self
          end

          def test_steps
            @test_steps ||= []
          end

          def around_hooks
            @around_hooks ||= []
          end

          def before_hooks
            @before_hooks ||= []
          end

          def after_hooks
            @after_hooks ||= []
          end

          # Passed to users in the mappings to add hooks to a scenario
          class DSL
            attr_reader :mapper, :hook_factory
            private     :mapper, :hook_factory

            def initialize(mapper, hook_factory)
              @mapper       = mapper
              @hook_factory = hook_factory
            end

            # Run this block of code before the scenario
            def before(&block)
              mapper.before_hooks << hook_factory.before(block)
              self
            end

            # Run this block of code after the scenario
            def after(&block)
              mapper.after_hooks.unshift(hook_factory.after(block))
              self
            end

            # Run this block of code around the scenario, with a yield in the block executing the scenario
            def around(&block)
              mapper.around_hooks << Hooks::AroundHook.new(&block)
              self
            end

          end
        end

        class StepMapper
          attr_accessor :test_step

          def initialize(test_step)
            @test_step = test_step
          end

          def before_step_hooks
            @before_step_hooks ||= []
          end

          def after_step_hooks
            @after_step_hooks ||= []
          end

          # Passed to users in the mappings to define and add hooks to a step
          class DSL
            attr_reader :mapper, :hook_factory
            private     :mapper, :hook_factory

            def initialize(mapper, hook_factory)
              @mapper       = mapper
              @hook_factory = hook_factory
            end

            def before(&block)
              mapper.before_step_hooks << hook_factory.before_step(block)
            end

            # Define the step with a block of code to be executed
            def map(&block)
              mapper.test_step = mapper.test_step.with_action(&block)
              self
            end

            # Define a block of code to be run after the step
            def after(&block)
              mapper.after_step_hooks << hook_factory.after_step(block)
              self
            end

          end
        end

        class HookFactory
          attr_accessor :source

          def initialize(source)
            @source = source
          end

          def after(block)
            build_hook_step(block, Hooks::AfterHook, Test::UnskippableAction)
          end

          def before(block)
            build_hook_step(block, Hooks::BeforeHook, Test::UnskippableAction)
          end

          def before_step(block)
            build_hook_step(block, Hooks::BeforeStepHook, Test::UnskippableAction)
          end

          def after_step(block)
            build_hook_step(block, Hooks::AfterStepHook, Test::Action)
          end

          private

          def build_hook_step(block, hook_type, mapping_type)
            mapping = mapping_type.new(&block)
            hook = hook_type.new(mapping.location)
            Step.new(source + [hook], mapping)
          end

        end


      end
    end
  end
end
