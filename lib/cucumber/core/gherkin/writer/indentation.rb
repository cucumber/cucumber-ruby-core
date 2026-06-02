# frozen_string_literal: true

module Cucumber
  module Core
    module Gherkin
      module Writer
        module Indentation
          def indentation_level(number)
            create_indent(number)
            create_indent_level(number)
            create_prepare_statements
          end

          private

          def create_indent(number)
            define_method(:indent) do |string, amount = nil|
              return string if string.nil? || string.empty?

              amount ||= number
              "#{' ' * amount}#{string}"
            end
          end

          def create_indent_level(number)
            define_method(:indent_level) do
              number
            end
          end

          def create_prepare_statements
            define_method(:prepare_statements) do |*statements|
              statements.flatten.compact.map { |s| indent(s) }
            end
          end
        end
      end
    end
  end
end
