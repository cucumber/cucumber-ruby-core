require 'cucumber/initializer'
require 'cucumber/core/test_suite'
require 'cucumber/core/test_case'
require 'cucumber/core/test_step'

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
          TestSuite.new(@feature_compiler.test_cases)
        end

        class FeatureCompiler
          include Cucumber.initializer(:feature)

          def background(background, &descend)
            source = [feature, background]
            @background_compiler = StepCompiler.new(source)
            descend.call(@background_compiler)
          end

          def scenario(scenario, &descend)
            source = [feature, scenario]
            scenario_compiler = StepCompiler.new(source)
            descend.call(scenario_compiler)
            scenario_test_steps = background_test_steps + scenario_compiler.test_steps
            test_cases << TestCase::Scenario.new(scenario_test_steps, source)
          end

          def test_cases
            @test_cases ||= []
          end

          private

          def background_test_steps
            return [] unless @background_compiler
            @background_compiler.test_steps
          end
        end

        class StepCompiler
          include Cucumber.initializer(:source)

          def test_steps
            steps.map do |step|
              TestStep.new(source + [step])
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
