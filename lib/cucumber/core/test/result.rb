# encoding: UTF-8¬
require 'cucumber/initializer'

module Cucumber
  module Core
    module Test
      module Result

        # Defines predicate methods on a result class with only the given one
        # returning true
        def self.status_queries(status)
          Module.new do
            [:passed, :failed, :undefined, :unknown, :skipped, :pending].each do |possible_status|
              define_method("#{possible_status}?") do
                possible_status == status
              end
            end
          end
        end

        # Null object for results. Represents the state where we haven't run anything yet
        class Unknown
          include Result.status_queries :unknown

          def describe_to(visitor, *args)
            self
          end
        end

        class Passed
          include Result.status_queries(:passed)
          include Cucumber.initializer(:duration)
          attr_reader :duration

          def initialize(duration)
            raise ArgumentError unless duration
            super
          end

          def describe_to(visitor, *args)
            visitor.passed(*args)
            visitor.duration(duration, *args)
            self
          end

          def to_s
            "✓"
          end
        end

        class Failed
          include Result.status_queries(:failed)
          include Cucumber.initializer(:duration, :exception)
          attr_reader :duration, :exception

          def initialize(duration, exception)
            raise ArgumentError unless duration 
            raise ArgumentError unless exception
            super
          end

          def describe_to(visitor, *args)
            visitor.failed(*args)
            visitor.duration(duration, *args)
            visitor.exception(exception, *args) if exception
            self
          end

          def to_s
            "✗"
          end

          def with_duration(new_duration)
            self.class.new(new_duration, exception)
          end

        end

        # Base class for exceptions that can be raised in a step defintion causing 
        # the step to have that result.
        class Raisable < StandardError
          attr_reader :message, :duration

          def initialize(message = "", duration = UnknownDuration.new, backtrace = nil)
            @message, @duration = message, duration
            super(message)
            set_backtrace(backtrace) if backtrace
          end

          def with_message(new_message)
            self.class.new(new_message, duration, backtrace)
          end

          def with_duration(new_duration)
            self.class.new(message, new_duration, backtrace)
          end
        end

        class Undefined < Raisable
          include Result.status_queries :undefined

          def describe_to(visitor, *args)
            visitor.undefined(*args)
            visitor.duration(duration, *args)
            self
          end

          def to_s
            "?"
          end

        end

        class Skipped < Raisable
          include Result.status_queries :skipped

          def describe_to(visitor, *args)
            visitor.skipped(*args)
            visitor.duration(duration, *args)
            self
          end

          def to_s
            "-"
          end

        end

        class Pending < Raisable
          include Result.status_queries :pending

          def describe_to(visitor, *args)
            visitor.pending(self, *args)
            visitor.duration(duration, *args)
            self
          end

          def to_s
            "P"
          end
        end

        #
        # An object that responds to the description protocol from the results
        # and collects summary information.
        #
        # e.g. 
        #     summary = Result::Summary.new
        #     Result::Passed.new(0).describe_to(summary)
        #     puts summary.total_passed
        #     => 1
        #
        class Summary
          attr_reader :total_failed,
            :total_passed,
            :total_skipped,
            :total_undefined,
            :exceptions,
            :durations

          def initialize
            @total_failed =
              @total_passed =
              @total_skipped =
              @total_undefined = 0
            @exceptions = []
            @durations = []
          end

          def failed(*args)
            @total_failed += 1
            self
          end

          def passed(*args)
            @total_passed += 1
            self
          end

          def skipped(*args)
            @total_skipped +=1
            self
          end

          def undefined(*args)
            @total_undefined += 1
            self
          end

          def exception(exception)
            @exceptions << exception
            self
          end

          def duration(duration)
            @durations << duration
            self
          end

          def total
            total_passed + total_failed + total_skipped + total_undefined
          end
        end

        class Duration
          attr_reader :duration

          def initialize(duration)
            @duration = duration
          end

          def exist?
            true
          end
        end

        class UnknownDuration
          def exist?
            false
          end

          def duration
            0
          end
        end
      end
    end
  end
end
