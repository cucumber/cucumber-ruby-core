require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test

      class Mapping
        def initialize(test_step, &block)
          raise ArgumentError, "Passing a block to execute the mapping is mandatory." unless block
          @block = block
          @test_step = test_step
        end

        def skip
          Result::Skipped.new(@test_step)
        end

        def execute
          @block.call
          Result::Passed.new(@test_step)
        rescue Exception => exception
          Result::Failed.new(@test_step, exception)
        end

      end

      class UndefinedMapping
        def initialize(test_step)
          @test_step = test_step
        end

        def execute
          undefined
        end

        def skip
          undefined
        end

        private

        def undefined
          Result::Undefined.new(@test_step)
        end

      end

    end
  end
end
