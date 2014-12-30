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

        def skip(last_result)
          skipped
        end

        def execute(last_result)
          @timer.start
          @block.call(last_result)
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

      class UnskippableAction < Action
        def skip(last_result)
          execute(last_result)
        end
      end

      class UndefinedAction
        def execute(last_result)
          undefined
        end

        def skip(last_result)
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
