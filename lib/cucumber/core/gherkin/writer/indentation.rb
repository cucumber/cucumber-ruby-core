# frozen_string_literal: true

module Cucumber
  module Core
    module Gherkin
      module Writer
        module Indentation
          def self.level(number)
            Module.new do
              define_method(:indent) do |string, amount = nil|
                return string if string.nil? || string.empty?

                amount ||= number
                "#{' ' * amount}#{string}"
              end

              define_method(:indent_level) do
                number
              end

              define_method(:prepare_statements) do |*statements|
                statements.flatten.compact.map { |s| indent(s) }
              end
            end
          end
        end
      end
    end
  end
end
