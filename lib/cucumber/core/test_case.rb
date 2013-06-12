require 'cucumber/initializer'
require 'cucumber/core/result'

module Cucumber
  module Core
    module TestCase
      class Scenario
        include Cucumber.initializer(:test_steps, :source)

        def initialize(test_steps, *source)
          super(test_steps, source)
        end

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
          source.each do |node|
            node.describe_to(visitor, *args)
          end
        end

      end
    end
  end
end
