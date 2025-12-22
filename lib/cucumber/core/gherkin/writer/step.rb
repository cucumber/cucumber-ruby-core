# frozen_string_literal: true

require_relative 'helpers'

require_relative 'doc_string'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class Step
          include HasElements
          include HasOptionsInitializer
          include Indentation.level 4

          default_keyword 'Given'

          elements :table

          def doc_string(string, content_type = '')
            elements << DocString.new(string, content_type)
          end

          private

          def statements
            prepare_statements comments_statement, name_statement
          end

          def name_statement
            "#{keyword} #{name}"
          end
        end
      end
    end
  end
end
