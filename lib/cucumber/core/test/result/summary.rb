# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        # An object that responds to the description protocol from the results and collects summary information.
        #
        # e.g.
        #     summary = Result::Summary.new
        #     Result::Passed.new(0).describe_to(summary)
        #     puts summary.total_passed
        #     => 1
        #
        class Summary
          TYPES = %i[failed ambiguous flaky skipped undefined pending passed unknown].freeze

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
              return false if get_total(type).positive? && !with_type(type).ok?
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

          def with_type(type)
            Object.const_get("Cucumber::Core::Test::Result::#{type.capitalize}")
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
      end
    end
  end
end
