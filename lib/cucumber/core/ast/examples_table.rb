require 'cucumber/initializer'
require 'cucumber/core/ast/describes_itself'

module Cucumber
  module Core
    module Ast

      class ExamplesTable
        include DescribesItself

        attr_reader :header, :location, :keyword, :name, :tags

        include Cucumber.initializer(
          :location, :comment, :tags, :keyword, :name, :description, :header, :example_rows
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

          def build_row(row_cells, number)
            Row.new(Hash[@cells.zip(row_cells)], number)
          end
        end

        class Row
          include DescribesItself

          attr_reader :number

          def initialize(data, number)
            raise ArgumentError, data.to_s unless data.is_a?(Hash)
            @data = data
            @number = number
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
