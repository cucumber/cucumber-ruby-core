require 'cucumber/initializer'
require 'cucumber/core/result'

module Cucumber
  module Core
    class TestStep

      def initialize(parents)
        @parents = parents
      end

      def execute(mappings)
        mappings.execute(step)
        Result::Passed.new(self)
      rescue Exception => exception
        Result::Failed.new(self, exception)
      end

      def describe_to(visitor, *args)
        parents.each do |parent|
          parent.describe_to(visitor, *args)
        end
      end

      attr_reader :parents
      private :parents

      def step
        parents.last
      end

    end
  end
end
