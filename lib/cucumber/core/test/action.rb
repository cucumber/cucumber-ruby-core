# frozen_string_literal: true
require 'cucumber/core/test/result'
require 'cucumber/core/test/timer'
require 'cucumber/core/test/result'
require 'cucumber/core/test/location'
require 'cucumber/core/test/invoke_result'

module Cucumber
  module Core
    module Test
      class Action
        def initialize(location = nil, &block)
          raise ArgumentError, "Passing a block to execute the action is mandatory." unless block
          @location = location ? location : Test::Location.new(*block.source_location)
          @block = block
          @timer = Timer.new
        end

        def skip(*)
          skipped
        end

        def execute(*args)
          @timer.start
          invoke_result = @block.call(*args)

          case invoke_result
          when PassedInvokeResult; then passed(invoke_result.embeddings)
          when FailedInvokeResult; then failed(invoke_result.exception, invoke_result.embeddings)
          else passed
          end
        rescue Result::Raisable => exception
          exception.with_duration(@timer.duration)
        rescue Exception => exception
          failed(exception)
        end

        def location
          @location
        end

        def inspect
          "#<#{self.class}: #{location}>"
        end

        private

        def passed(embeddings = [])
          Result::Passed.new(@timer.duration, embeddings)
        end

        def failed(exception, embeddings = [])
          Result::Failed.new(@timer.duration, exception, embeddings)
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
        attr_reader :location

        def initialize(source_location)
          @location = source_location
        end

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
