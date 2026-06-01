# frozen_string_literal: true

require_relative 'base'

module Cucumber
  module Core
    module Events
      # Signals that a gherkin source has been parsed
      class GherkinSourceParsed < Base
        # @return [GherkinDocument] the GherkinDocument Ast Node that was parsed
        attr_reader :gherkin_document

        def self.event_id
          :gherkin_source_parsed
        end

        def initialize(gherkin_document)
          @gherkin_document = gherkin_document
          super()
        end
      end
    end
  end
end
