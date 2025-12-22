# frozen_string_literal: true

require_relative 'helpers'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class Background
          include HasElements
          include HasOptionsInitializer
          include HasDescription
          include Indentation.level 2

          default_keyword 'Background'

          elements :step

          private

          def statements
            prepare_statements(
              comments_statement,
              tag_statement,
              name_statement,
              description_statement
            )
          end
        end
      end
    end
  end
end
