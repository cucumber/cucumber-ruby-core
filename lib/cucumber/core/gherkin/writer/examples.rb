# frozen_string_literal: true

require_relative 'helpers'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class Examples
          NEW_LINE = ''

          include HasOptionsInitializer
          include HasRows
          include HasDescription
          include Indentation.level(4)

          default_keyword 'Examples'

          def build(source)
            source + statements
          end

          private

          def statements
            prepare_statements(
              NEW_LINE,
              comments_statement,
              tag_statement,
              name_statement,
              description_statement,
              row_statements(2)
            )
          end
        end
      end
    end
  end
end
