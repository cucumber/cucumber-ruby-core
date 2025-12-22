# frozen_string_literal: true

require_relative '../event'

module Cucumber
  module Core
    module Events
      # Signals that a gherkin source has been parsed
      class GherkinSourceParsed < Event.new(:gherkin_document)
        # @return [GherkinDocument] the GherkinDocument Ast Node
        attr_reader :gherkin_document
      end
    end
  end
end
