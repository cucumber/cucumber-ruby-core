require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test

      class Mapping
        def initialize(&block)
          raise ArgumentError, "Passing a block to execute the mapping is mandatory." unless block
          @block = block
        end

        def skip
          Result::Skipped.new
        end

        def execute
          @block.call
          Result::Passed.new
        rescue Exception => exception
          Result::Failed.new(exception)
        end

      end

      class UndefinedMapping
        def execute
          undefined
        end

        def skip
          undefined
        end

        private

        def undefined
          Result::Undefined.new
        end

      end

    end
  end
end
