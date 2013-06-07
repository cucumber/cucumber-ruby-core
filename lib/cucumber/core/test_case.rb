require 'cucumber/initialize'
require 'cucumber/core/describes_itself'

module Cucumber
  module Core
    module TestCase
      class Scenario
        include DescribesItself
        include Cucumber::Initialize(:feature, :scenario, :test_steps)

        def execute(mappings, report)
          report.before_test_case(self)
          # TODO: Execute steps
          report.after_test_case(self)
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
