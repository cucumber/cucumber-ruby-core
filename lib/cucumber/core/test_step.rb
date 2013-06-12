require 'cucumber/initializer'
require 'cucumber/core/result'

module Cucumber
  module Core
    class TestStep
      include Cucumber.initializer(:parents)

      def execute(mappings)
        mappings.execute(step)
        Result::Passed.new(self)
      rescue Exception => exception
        Result::Failed.new(self, exception)
      end

      def describe_to(visitor, *args)
        visitor.test_step(self, *args)
      end

      def describe_source_to(visitor, *args)
        parents.each do |parent|
          parent.describe_to(visitor, *args)
        end
      end

      def step
        parents.last
      end

    end
  end
end
