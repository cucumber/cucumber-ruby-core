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
              # TODO: clean this up - can it be moved down to gherkin/rubify?
              line_range = argument.line_range.first..argument.line_range.last
              Ast::DocString.new(argument.value, argument.content_type, parent_location.on_line(line_range))
            when Array
              # TODO: clean this up - can it be moved down to gherkin/rubify?
              lines = argument.map(&:line)
              location = parent_location.on_line(lines.first..lines.last)
              Ast::DataTable.new(argument.map{|row| row.cells}, location)
            else
              raise ArgumentError, "Don't know how to convert #{argument} into a MultilineArgument"
            end
          end

        end
      end
    end
  end
end
