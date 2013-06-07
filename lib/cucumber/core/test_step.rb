require 'cucumber/initializer'
require 'cucumber/core/describes_itself'
require 'cucumber/core/result'

module Cucumber
  module Core
    class TestStep
      include DescribesItself
      include Cucumber.initializer(:step, :parents)

      def initialize(parents)
        step = parents.pop
        super(step, parents)
      end

      def execute(mappings)
        mappings.execute(step)
        Result::Passed.new(self)
      rescue Exception
        Result::Failed.new(self)
      end

      def children
        [step]
      end

      def description_for_visitors
        :test_step
      end

    end
  end
end
