require 'cucumber/initializer'
module Cucumber
  module Core
    class TestSuite
      include DescribesItself
      include Cucumber.initializer(:test_cases)

      def execute(mappings, report)
        test_cases.each do |test_case|
          test_case.execute(mappings, report)
        end
        self
      end

      private

      def children
        test_cases
      end

      def description_for_visitors
        :test_suite
      end
    end
  end
end
