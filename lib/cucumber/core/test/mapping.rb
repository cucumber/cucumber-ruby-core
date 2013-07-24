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
          start = time_in_nanoseconds
          @block.call
          duration = time_in_nanoseconds - start
          Result::Passed.new(duration)
        rescue Exception => exception
          duration = time_in_nanoseconds - start
          Result::Failed.new(duration, exception)
        end

        private

        def time_in_nanoseconds
          Time.now.nsec
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
