require 'cucumber/core/test/result'
require 'cucumber/core/test/timer'
require 'cucumber/core/test/result'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Test
      class Action
        def initialize(&block)
          raise ArgumentError, "Passing a block to execute the action is mandatory." unless block
          @block = block
          @timer = Timer.new
        end

        def skip(*)
          skipped
        end

        def execute(*args)
          @timer.start
          @block.call(*args)
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
          "#<#{self.class}: #{location}>"
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

      class UnskippableAction < Action
        def skip(*args)
          execute(*args)
        end
      end

      class UndefinedAction
        def execute(*)
          undefined
        end

        def skip(*)
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
