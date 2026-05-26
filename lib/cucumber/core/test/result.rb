# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

require_relative 'result/boolean_methods'

require_relative 'result/raisable'

require_relative 'result/ambiguous'
require_relative 'result/failed'
require_relative 'result/flaky'
require_relative 'result/passed'
require_relative 'result/pending'
require_relative 'result/skipped'
require_relative 'result/undefined'
require_relative 'result/unknown'

module Cucumber
  module Core
    module Test
      module Result
        TYPES = %i[failed ambiguous flaky skipped undefined pending passed unknown].freeze

        def self.ok?(type)
          class_name = type.to_s.slice(0, 1).capitalize + type.to_s.slice(1..-1)
          const_get(class_name).ok?
        end

        # An object that responds to the description protocol from the results and collects summary information.
        #
        # e.g.
        #     summary = Result::Summary.new
        #     Result::Passed.new(0).describe_to(summary)
        #     puts summary.total_passed
        #     => 1
        #
        class Summary
          attr_reader :exceptions, :durations

          def initialize
            @totals = Hash.new { 0 }
            @exceptions = []
            @durations = []
          end

          def method_missing(name, *_args)
            if name =~ /^total_/
              get_total(name)
            else
              increment_total(name)
            end
          end

          def respond_to_missing?(*)
            true
          end

          def ok?
            TYPES.each do |type|
              return false if get_total(type).positive? && !Result.ok?(type)
            end
            true
          end

          def exception(exception)
            @exceptions << exception
            self
          end

          def duration(duration)
            @durations << duration
            self
          end

          def total(for_status = nil)
            if for_status
              @totals.fetch(for_status, 0)
            else
              @totals.values.reduce(0) { |total, count| total + count }
            end
          end

          def decrement_failed
            @totals[:failed] -= 1
          end

          private

          def get_total(method_name)
            status = method_name.to_s.gsub('total_', '').to_sym
            @totals.fetch(status, 0)
          end

          def increment_total(status)
            @totals[status] += 1
            self
          end
        end

        class Duration
          include Cucumber::Messages::Helpers::TimeConversion

          attr_reader :nanoseconds

          def initialize(nanoseconds)
            @nanoseconds = nanoseconds
          end

          def to_message_duration
            duration_hash = seconds_to_duration(nanoseconds.to_f / NANOSECONDS_PER_SECOND)
            Cucumber::Messages::Duration.new(seconds: duration_hash[:seconds], nanos: duration_hash[:nanos])
          end

          def seconds_to_duration(seconds_float)
            seconds, second_modulus = seconds_float.divmod(1)
            nanos = second_modulus * NANOSECONDS_PER_SECOND
            { seconds: seconds, nanos: nanos.to_i }
          end
        end

        class UnknownDuration
          def tap
            self
          end

          def nanoseconds
            raise '#nanoseconds only allowed to be used in #tap block'
          end

          def to_message_duration
            Cucumber::Messages::Duration.new(seconds: 0, nanos: 0)
          end
        end
      end
    end
  end
end
