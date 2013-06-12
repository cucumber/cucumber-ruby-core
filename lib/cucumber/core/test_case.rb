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
          result = Result::Unknown.new
          report.before_test_case(self)
          test_steps.each do |test_step|
            report.before_test_step(test_step)
            result = test_step.execute(mappings)
            report.after_test_step(test_step, result)
          end
          report.after_test_case(self, result)
          result
        end

        def describe_to(visitor, *args)
          visitor.test_case(self, *args) do
            test_steps.each do |test_step|
              test_step.describe_to(visitor, *args)
            end
          end
        end

        def describe_source_to(visitor, *args)
          [feature, scenario].each do |node|
            node.describe_to(visitor, *args)
          end
        end

        private

        def children
          test_steps
        end

        def description_for_visitors
          :test_case
        end
      end
    end
  end
end
