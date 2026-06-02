# frozen_string_literal: true

require_relative 'helpers'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class Table
          extend Indentation

          indentation_level 6

          include HasRows

          def initialize(*); end

          def build(source)
            source + statements
          end

          private

          def statements
            row_statements
          end
        end
      end
    end
  end
end
