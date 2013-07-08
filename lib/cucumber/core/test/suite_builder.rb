module Cucumber
  module Core
    module Test
      class SuiteBuilder
        def test_case(test_case)
          test_cases << test_case
        end

        def result
          Test::Suite.new(test_cases)
        end

        private

        def test_cases
          @test_cases ||= []
        end
      end

    end
  end
end
