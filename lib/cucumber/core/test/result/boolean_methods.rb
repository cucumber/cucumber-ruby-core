# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        # Simple module that when included generates all the boolean methods for each category of result
        # The single exception to this is the class method `self.ok?` which is defined for each result individually
        module BooleanMethods
          TYPES = %i[failed ambiguous flaky undefined pending skipped passed unknown].freeze

          TYPES.each do |result|
            define_method("#{result}?") do
              result == to_sym
            end
          end

          def ok?
            self.class.ok?
          end
        end
      end
    end
  end
end
