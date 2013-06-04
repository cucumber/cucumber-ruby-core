module Cucumber
  module Core
    class TestSuite
      attr_reader :test_cases

      def initialize(test_cases)
        @test_cases = test_cases
      end
    end
  end
end
