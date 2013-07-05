require 'cucumber/initializer'
require 'cucumber/core/test/suite'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber
  module Core
    class Compiler
      def initialize(ast)
        @ast = ast
      end

      def test_suite
        TestSuiteBuilder.new.tap do |builder|
          @ast.each { |feature| feature.describe_to(builder) }
        end.test_suite
      end

      class TestSuiteBuilder
        def initialize
          @test_cases = []
        end

        def feature(feature, &descend)
          feature_compiler = FeatureCompiler.new(feature, self)
          descend.call(feature_compiler)
        end

        def background_steps(test_steps)
          @background_test_steps = test_steps
        end

        def test_case(test_steps, source)
          @test_cases << Test::Case.new(background_test_steps + test_steps, source)
        end

        def test_suite
          Test::Suite.new(@test_cases)
        end

        private

        def background_test_steps
          @background_test_steps || []
        end

        class FeatureCompiler
          include Cucumber.initializer(:feature, :receiver)

          def background(background, &descend)
            source = [feature, background]
            compiler = StepsCompiler.new(source)
            descend.call(compiler)
            receiver.background_steps(compiler.test_steps)
          end

          def scenario(scenario, &descend)
            source = [feature, scenario]
            scenario_compiler = StepsCompiler.new(source)
            descend.call(scenario_compiler)
            receiver.test_case(scenario_compiler.test_steps, source)
          end

          def scenario_outline(scenario_outline, &descend)
            source = [feature, scenario_outline]
            compiler = ScenarioOutlineCompiler.new(source, receiver)
            descend.call(compiler)
          end
        end

        class ScenarioOutlineCompiler
          include Cucumber.initializer(:source, :receiver)

          def outline_step(outline_step)
            outline_steps << outline_step
          end

          def examples_table(examples_table, &descend)
            @source << examples_table
            descend.call
          end

          def examples_table_row(row)
            receiver.test_case(test_steps(row), @source)
          end

          private

          def test_steps(row)
            steps(row).map do |step|
              Test::Step.new(@source + [row, step])
            end
          end

          def steps(row)
            outline_steps.map { |s| s.to_step(row) }
          end

          def outline_steps
            @outline_steps ||= []
          end
        end

        class StepsCompiler
          include Cucumber.initializer(:source)

          def test_steps
            steps.map do |step|
              Test::Step.new(source + [step])
            end
          end

          def step(step)
            steps << step
          end

          private

          def steps
            @steps ||= []
          end
        end

      end
    end
  end
end
