require 'cucumber/initializer'
require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test
      class Case
        include Cucumber.initializer(:test_steps, :source)

        def describe_to(visitor, *args)
          visitor.test_case(self, *args) do
            test_steps.each do |test_step|
              test_step.describe_to(visitor, *args)
            end
          end
          self
        end

        def describe_source_to(visitor, *args)
          source.each do |node|
            node.describe_to(visitor, *args)
          end
          self
        end

      end
    end
  end
end
