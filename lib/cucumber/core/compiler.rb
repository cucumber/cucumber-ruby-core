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
        def background_test_step(source)
          background_test_steps << Test::Step.new(source)
        end

        def test_case(source)
          test_cases << Test::Case.new(test_steps, source)
          @test_steps = nil
        end

        def test_step(source)
          test_steps << Test::Step.new(source)
        end

        def result
          Test::Suite.new(@test_cases)
        end

        private

        def background_test_steps
          @background_test_steps ||= []
        end

        def test_cases
          @test_cases ||= []
        end

        def test_steps
          @test_steps ||= background_test_steps.dup
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
          compiler = BackgroundCompiler.new(source, receiver)
          descend.call(compiler)
        end

        def scenario(scenario, &descend)
          source = [@feature, scenario]
          scenario_compiler = ScenarioCompiler.new(source, receiver)
          descend.call(scenario_compiler)
          receiver.test_case(source)
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
          source << examples_table
          descend.call
        end

        def examples_table_row(row)
          steps(row).each do |step|
            receiver.test_step(source + [row, step])
          end
          receiver.test_case(source)
        end

        private

        def steps(row)
          outline_steps.map { |s| s.to_step(row) }
        end

        def outline_steps
          @outline_steps ||= []
        end
      end

      class ScenarioCompiler
        include Cucumber.initializer(:source, :receiver)

        def step(step)
          receiver.test_step(source + [step])
        end
      end

      class BackgroundCompiler
        include Cucumber.initializer(:source, :receiver)

        def step(step)
          receiver.background_test_step(source + [step])
        end
      end

    end
  end
end
