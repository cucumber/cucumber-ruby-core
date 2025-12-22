# frozen_string_literal: true

require_relative 'helpers'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class ScenarioOutline
          include HasElements
          include HasOptionsInitializer
          include HasDescription
          include Indentation.level 2

          default_keyword 'Scenario Outline'

          elements :step, :examples

          private

          def statements
            prepare_statements comments_statement, tag_statement, name_statement, description_statement
          end
        end
      end
    end
  end
end
