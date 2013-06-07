require 'cucumber/initializer'
require 'cucumber/core/describes_itself'
require 'cucumber/core/result'

module Cucumber
  module Core
    module TestCase
      class Scenario
        include DescribesItself
        include Cucumber.initializer(:feature, :scenario, :test_steps)

        def execute(mappings, report)
          result = Runner.new(mappings, report).execute(test_steps)
        end

        private
        def children
          test_steps
        end

        def description_for_visitors
          :test_case
        end
      end

      class Runner
        include Cucumber.initializer(:mappings, :report)

        def execute(test_steps)
          result = Result::Unknown.new
          report.before_test_case(self)
          test_steps.each do |test_step|
            result = test_step.execute(mappings)
          end
          report.after_test_case(self, result)
          result
        end

      end
    end
  end
end
