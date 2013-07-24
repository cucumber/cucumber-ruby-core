require 'cucumber/core/test/result'

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
        rescue Exception => exception
          failed(exception)
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

        class Timer
          def start
            @start_time = time_in_nanoseconds
          end

          def duration
            time_in_nanoseconds - @start_time
          end

          private

          def time_in_nanoseconds
            Time.now.nsec
          end
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
