require 'cucumber/core/describes_itself'
require 'cucumber/core/test_suite'
require 'cucumber/core/test_case'

module Cucumber
  module Core
    class Compiler
      def initialize(features)
        @features = features
      end

      def test_suite
        TestSuiteBuilder.new.tap do |builder|
          @features.each { |f| f.describe_to(builder) }
        end.result
      end

      class TestSuiteBuilder
        attr_reader :current_feature
        private :current_feature

        def initialize
          @test_cases = []
        end

        def feature(feature, &descend)
          @current_feature = feature
          descend.call
        end

        def scenario(scenario, &descend)
          test_case_builders << ScenarioBuilder.new(current_feature, scenario)
          descend.call(test_case_builders.last)
        end

        def result
          TestSuite.new(test_cases)
        end

        private

        def test_cases
          test_case_builders.map(&:result)
        end

        def test_case_builders
          @test_case_builders ||= []
        end

        class ScenarioBuilder
          attr_reader :feature, :scenario
          private :feature, :scenario

          def initialize(feature, scenario)
            @feature = feature
            @scenario = scenario
          end

          def result
            TestCase::Scenario.new(feature, scenario, test_steps)
          end

          def step(step)
            parents = [feature, scenario, step]
            test_steps << TestStep.new(parents)
          end

          private
          def test_steps
            @test_steps ||= []
          end
        end

        class TestStep
          include DescribesItself
          def initialize(parents)

          end

          def description_for_visitors
            :test_step
          end
        end

      end
    end
  end
end
