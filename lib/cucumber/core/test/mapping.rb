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

        def skip(status)
          skipped
        end

        def execute(status)
          @timer.start
          @block.call(status)
          passed
        rescue Result::Raisable => exception
          exception.with_duration(@timer.duration)
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
      end

      class UnskippableMapping < Mapping
        def skip(status)
          execute(status)
        end
      end

      class UndefinedMapping
        def execute(status)
          undefined
        end

        def skip(status)
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
