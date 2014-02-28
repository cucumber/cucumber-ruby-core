require 'gherkin/rubify'

module Cucumber
  module Core
    module Ast
      module MultilineArgument

        class << self
          include Gherkin::Rubify

          # TODO: move this up to the front-end
          def from(argument, parent_location)
            return EmptyMultilineArgument.new unless argument
            return argument if argument.respond_to?(:to_step_definition_arg)

            argument = rubify(argument)
            case argument
            when String
              Ast::DocString.new(argument, 'text/plain', parent_location)
            when ::Gherkin::Formatter::Model::DocString
              Ast::DocString.new(argument.value, argument.content_type, parent_location.on_line(argument.line_range))
            when Array
              location = parent_location.on_line(argument.first.line..argument.last.line)
              Ast::DataTable.new(argument.map{|row| row.cells}, location)
            else
              raise ArgumentError, "Don't know how to convert #{argument.inspect} into a MultilineArgument"
            end
          end

        end
      end
    end
  end
end
