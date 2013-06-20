require 'cucumber/initializer'
require 'cucumber/core/test/suite_runner'

module Cucumber
  module Core
    module Test

      class Suite
        include Cucumber.initializer(:test_cases)

        def execute(mappings, report)
          describe_to(Test::SuiteRunner.new(mappings, report))
          self
        end

        def describe_to(visitor, *args)
          visitor.test_suite(self, *args) do
            test_cases.each do |test_case|
              test_case.describe_to(visitor, *args)
            end
          end
          self
        end
      end

    end
  end
end
