# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a gherkin source has been parsed
      class GherkinSourceParsed < Event.new(:gherkin_document)
        # @return [GherkinDocument] the GherkinDocument Ast Node that was parsed
      end
    end
  end
end
