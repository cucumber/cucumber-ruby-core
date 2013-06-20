require 'cucumber/initializer'
require 'cucumber/core/ast/describes_itself'

module Cucumber
  module Core
    module Ast

      class ExamplesTable
        include DescribesItself

        attr_reader :header

        include Cucumber.initializer(
          :location, :comment, :keyword, :name, :description, :header, :example_rows
        )

        private

        def description_for_visitors
          :examples_table
        end

        def children
          @example_rows
        end

        class Header
          def initialize(cells)
            @cells = cells
          end

          def ==(other)
            other == @cells
          end

          def build_row(row_cells)
            Row.new(Hash[@cells.zip(row_cells)])
          end
        end

        class Row
          include DescribesItself

          def initialize(data)
            raise ArgumentError, data.to_s unless data.is_a?(Hash)
            @data = data
          end

          def ==(other)
            other == @data
          end

          def values
            @data.values
          end

          def expand(string)
            result = string.dup
            @data.each do |key, value|
              result.gsub!("<#{key}>", value.to_s)
            end
            result
          end

          def inspect
            @data.inspect
          end

          private

          def description_for_visitors
            :examples_table_row
          end

          def children
            []
          end
        end

      end

    end
  end
end
