require 'cucumber/initializer'
require 'cucumber/core/test/result'
require 'cucumber/core/test/mapping'

module Cucumber
  module Core
    module Test
      class Step
        include Cucumber.initializer(:source)

        def initialize(source)
          raise ArgumentError if source.any?(&:nil?)
          @mapping = nil
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

        def skip
          mapping.skip
          Result::Skipped.new(self)
        rescue UndefinedMapping => exception
          Result::Undefined.new(self, exception)
        end

        def execute
          mapping.execute
          Result::Passed.new(self)
        rescue UndefinedMapping => exception
          Result::Undefined.new(self, exception)
        rescue Exception => exception
          Result::Failed.new(self, exception)
        end

        def name
          step.name
        end

        def define(&block)
          @mapping = Test::Mapping.new(&block)
        end

        private

        def step
          source.last
        end

        def mapping
          @mapping || Test::UndefinedMapping.new
        end

      end
    end
  end
end
