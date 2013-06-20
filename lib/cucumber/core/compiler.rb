require 'cucumber/initializer'
require 'cucumber/core/test/suite'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber
  module Core
    class Compiler
      def initialize(features)
        @features = features
      end

      def test_suite
        TestSuiteBuilder.new.tap do |builder|
          @features.each { |f| f.describe_to(builder) }
        end.test_suite
      end

      class TestSuiteBuilder
        def initialize
          @test_cases = []
        end

        def feature(feature, &descend)
          @feature_compiler = FeatureCompiler.new(feature)
          descend.call(@feature_compiler)
        end

        def test_suite
          Test::Suite.new(@feature_compiler.test_cases)
        end

        class FeatureCompiler
          include Cucumber.initializer(:feature)

          def background(background, &descend)
            source = [feature, background]
            @background_compiler = StepsCompiler.new(source)
            descend.call(background_compiler)
          end

          def scenario(scenario, &descend)
            source = [feature, scenario]
            scenario_compiler = StepsCompiler.new(source)
            descend.call(scenario_compiler)
            new_test_case(scenario_compiler.test_steps, source)
          end

          def scenario_outline(scenario_outline, &descend)
            source = [feature, scenario_outline]
            scenario_outline_compiler = ScenarioOutlineCompiler.new(source) do |test_steps, source|
              new_test_case(test_steps, source)
            end
            descend.call(scenario_outline_compiler)
          end

          def test_cases
            @test_cases ||= []
          end

          private

          def new_test_case(test_steps, source)
            test_steps = background_compiler.test_steps + test_steps
            test_cases << Test::Case.new(test_steps, source)
          end

          def background_compiler
            @background_compiler ||= StepsCompiler.new([feature])
          end
        end

        class ScenarioOutlineCompiler
          def initialize(source, &on_test_case)
            @source, @on_test_case = source, on_test_case
            @outline_steps = []
          end

          def outline_step(outline_step)
            @outline_steps << outline_step
          end

          def examples_table(examples_table, &descend)
            @source << examples_table
            descend.call
          end

          def examples_table_row(row)
            @on_test_case.call(test_steps(row), @source)
          end

          private

          def test_steps(row)
            steps(row).map do |step|
              Test::Step.new(@source + [row, step])
            end
          end

          def steps(row)
            @outline_steps.map { |s| s.to_step(row) }
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
