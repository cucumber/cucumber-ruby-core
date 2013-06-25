require 'cucumber/initializer'
require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test
      class Step
        include Cucumber.initializer(:source)

        def initialize(source)
          raise ArgumentError if source.any?(&:nil?)
          super
        end

        def describe_to(visitor, *args)
          visitor.test_step(self, *args)
        end

        def describe_source_to(visitor, *args)
          source.each do |node|
            node.describe_to(visitor, *args)
          end
        end

        def step
          source.last
        end

      end
    end
  end
end
