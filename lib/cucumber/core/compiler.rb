require 'cucumber/core/test_suite.rb'
module Cucumber
  module Core
    class Compiler
      def initialize(features)
        @features = features
      end

      def test_suite
        @features.inject(TestSuiteBuilder.new) do |builder, feature|
          builder.add_feature(feature)
        end.result
      end

      class TestSuiteBuilder
        attr_reader :current_feature
        private :current_feature

        def initialize
          @test_cases = []
        end

        def add_feature(feature)
          feature.describe_to(self)
          self
        end

        def feature(feature, &descend)
          @current_feature = feature
          descend.call
        end

        def scenario(scenario)
          new_scenario(current_feature, scenario)
        end

        def result
          TestSuite.new(@test_cases)
        end

        private
        def new_scenario(feature, scenario)
          @test_cases << :new_test_case
        end
      end
    end
  end
end
