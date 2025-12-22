# frozen_string_literal: true

require_relative 'helpers'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class Rule
          NEW_LINE = ''

          include HasElements
          include HasOptionsInitializer
          include HasDescription
          include Indentation.level 2

          default_keyword 'Rule'

          elements :example, :scenario

          private

          def statements
            prepare_statements(
              comments_statement,
              name_statement,
              description_statement,
              NEW_LINE
            )
          end
        end
      end
    end
  end
end
