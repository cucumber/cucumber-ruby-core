require 'cucumber/initializer'
module Cucumber
  module Core
    class TestSuite
      include Cucumber.initializer(:test_cases)

      def execute(mappings, report)
        test_cases.each do |test_case|
          test_case.execute(mappings, report)
        end
        self
      end

      def describe_to(visitor, *args)
        visitor.test_suite(self, *args) do
          test_cases.each do |test_case|
            test_case.describe_to(visitor, *args)
          end
        end
      end
    end
  end
end
