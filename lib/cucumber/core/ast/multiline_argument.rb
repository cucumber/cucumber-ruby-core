require 'gherkin/rubify'

module Cucumber
  module Core
    module Ast
      module MultilineArgument

        class << self
          include Gherkin::Rubify

          def from(argument, parent_location)
            return unless argument
            return argument if argument.respond_to?(:to_step_definition_arg)

            case(rubify(argument))
            when ::Gherkin::Formatter::Model::DocString
              Ast::DocString.new(argument.value, argument.content_type, parent_location.on_line(argument.line_range))
            when Array
              Ast::DataTable.new(argument.map{|row| row.cells})
            else
              raise ArgumentError, "Don't know how to convert #{argument} into a MultilineArgument"
            end
          end

        end
      end
    end
  end
end
