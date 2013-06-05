require 'cucumber/core/describes_itself'
module Cucumber
  module Core
    class TestStep
      include DescribesItself
      def initialize(parents)

      end

      def description_for_visitors
        :test_step
      end
    end
  end
end
