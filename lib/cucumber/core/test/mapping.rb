require 'cucumber/core/test/result'
require 'cucumber/core/test/timer'
require 'cucumber/core/test/result'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Test

      class Mapping
        def initialize(&block)
          raise ArgumentError, "Passing a block to execute the mapping is mandatory." unless block
          @block = block
          @timer = Timer.new
        end

        def skip
          skipped
        end

        def execute
          @timer.start
          @block.call
          passed
        rescue Result::Pending => exception
          pending(exception)
        rescue Result::Skipped => exception
          return exception
        rescue Exception => exception
          failed(exception)
        end

        def location
          Ast::Location.new(*@block.source_location)
        end

        def inspect
          "<#{self.class}: #{location}>"
        end

        private

        def passed
          Result::Passed.new(@timer.duration)
        end

        def failed(exception)
          Result::Failed.new(@timer.duration, exception)
        end

        def skipped
          Result::Skipped.new
        end

        def pending(exception)
          exception.with_duration(@timer.duration)
        end

      end

      class UnskippableMapping < Mapping
        def skip
          execute
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
