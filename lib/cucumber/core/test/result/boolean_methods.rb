# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        # Simple module that when included generates all the boolean methods for each category of result
        module BooleanMethods
          TYPES = %i[failed ambiguous flaky skipped undefined pending passed unknown].freeze

          TYPES.each do |result|
            define_method("#{result}?") do
              result == to_sym
            end
          end
        end
      end
    end
  end
end
