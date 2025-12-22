# frozen_string_literal: true

require_relative 'helpers'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class Feature
          NEW_LINE = ''

          include HasElements
          include HasOptionsInitializer
          include HasDescription
          include Indentation.level(0)

          default_keyword 'Feature'

          elements :background, :rule, :scenario, :scenario_outline

          def build(source = [])
            elements.inject(source + statements) { |acc, el| el.build(acc) + [NEW_LINE] }
          end

          private

          def language
            options[:language]
          end

          def statements
            prepare_statements(
              language_statement,
              comments_statement,
              tag_statement,
              name_statement,
              description_statement,
              NEW_LINE
            )
          end

          def language_statement
            "# language: #{language}" if language
          end
        end
      end
    end
  end
end
