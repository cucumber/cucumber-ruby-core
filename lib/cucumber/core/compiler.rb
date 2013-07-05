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
        builder = TestSuiteBuilder.new
        compiler = FeatureCompiler.new(builder)
        @ast.each { |feature| feature.describe_to(compiler) }
        builder.result
      end

      class TestSuiteBuilder
        def initialize
          @test_cases = []
        end

        def background_steps(test_steps)
          @background_test_steps = test_steps
        end

        def test_case(test_steps, source)
          @test_cases << Test::Case.new(background_test_steps + test_steps, source)
        end

        def test_step(source)
          Test::Step.new(source)
        end

        def result
          Test::Suite.new(@test_cases)
        end

        private

        def background_test_steps
          @background_test_steps || []
        end
      end

      class FeatureCompiler
        include Cucumber.initializer(:receiver)

        def feature(feature, &descend)
          @feature = feature
          descend.call(self)
        end

        def background(background, &descend)
          source = [@feature, background]
          compiler = StepsCompiler.new(source, receiver)
          descend.call(compiler)
          receiver.background_steps(compiler.test_steps)
        end

        def scenario(scenario, &descend)
          source = [@feature, scenario]
          scenario_compiler = StepsCompiler.new(source, receiver)
          descend.call(scenario_compiler)
          receiver.test_case(scenario_compiler.test_steps, source)
        end

        def scenario_outline(scenario_outline, &descend)
          source = [@feature, scenario_outline]
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
            receiver.test_step(@source + [row, step])
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
        include Cucumber.initializer(:source, :receiver)

        def test_steps
          steps.map do |step|
            receiver.test_step(source + [step])
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
