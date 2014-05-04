require 'cucumber/initializer'
require 'cucumber/core/test/hooks'

module Cucumber
  module Core
    module Test
      class Mapper
        include Cucumber.initializer(:user_mappings, :receiver)

        def test_case(test_case, &descend)
          compiler = CaseCompiler.new(user_mappings)
          test_case.describe_to user_mappings, CaseMapperDSL.new(compiler)
          descend.call(compiler)
          test_case.
            with_steps(compiler.before_hooks + compiler.test_steps + compiler.after_hooks).
            with_around_hooks(compiler.around_hooks).
            describe_to(receiver)
          self
        end

        def done
          receiver.done
          self
        end

        class CaseCompiler
          include Cucumber.initializer(:user_mappings)

          def test_step(test_step)
            compiler = StepCompiler.new(test_step)
            test_step.describe_to user_mappings, StepMapperDSL.new(compiler)
            test_steps.push(*[compiler.test_step] + compiler.after_step_hooks)
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
        end

        class StepCompiler
          include Cucumber.initializer(:test_step)

          attr_accessor :test_step

          def after_step_hooks
            @after_step_hooks ||= []
          end
        end

        # Passed to users in the mappings to add hooks to a scenario
        class CaseMapperDSL
          include Cucumber.initializer(:compiler)

          # Run this block of code before the scenario
          def before(&block)
            compiler.before_hooks << build_hook_step(block, BeforeHook)
            self
          end

          # Run this block of code after the scenario
          def after(&block)
            compiler.after_hooks << build_hook_step(block, AfterHook)
            self
          end

          # Run this block of code around the scenario, with a yield in the block executing the scenario
          def around(&block)
            compiler.around_hooks << AroundHook.new(&block)
            self
          end

          private

          def build_hook_step(block, type)
            mapping = Test::Mapping.new(&block)
            hook = type.new(mapping.location)
            Step.new([hook], mapping)
          end

        end

        # Passed to users in the mappings to define and add hooks to a step
        class StepMapperDSL
          include Cucumber.initializer(:compiler)

          # Define the step with a block of code to be executed
          def map(&block)
            compiler.test_step = compiler.test_step.with_mapping(&block)
            self
          end

          # Define a block of code to be run after the step
          def after(&block)
            compiler.after_step_hooks << build_hook_step(block, AfterStepHook)
            self
          end

          private

          def build_hook_step(block, type)
            mapping = Test::Mapping.new(&block)
            hook = type.new(mapping.location)
            Step.new([hook], mapping)
          end

        end

      end
    end
  end
end
