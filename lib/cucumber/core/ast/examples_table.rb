require 'cucumber/initializer'
require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast

      class ExamplesTable
        include HasLocation
        include DescribesItself

        attr_reader :header, :keyword, :name, :tags, :comments, :location

        include Cucumber.initializer(
          :location, :comments, :tags, :keyword, :name, :description, :header, :example_rows
        )

        def gherkin_statement(node=nil)
          @gherkin_statement ||= node
        end

        private

        def description_for_visitors
          :examples_table
        end

        def children
          @example_rows
        end

        class Header
          include HasLocation

          def initialize(cells, location)
            @cells = cells
            @location = location
          end

          def values
            @cells
          end

          def build_row(row_cells, number, location)
            Row.new(Hash[@cells.zip(row_cells)], number, location)
          end
        end

        class Row
          include DescribesItself
          include HasLocation

          attr_reader :number

          def initialize(data, number, location)
            raise ArgumentError, data.to_s unless data.is_a?(Hash)
            @data = data
            @number = number
            @location = location
          end

          def ==(other)
            return false unless other.class == self.class
            other.number == number &&
              other.location == location &&
              other.data == data
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
            "#{self.class}: #{@data.inspect}"
          end

          protected

          attr_reader :data

          private

          def description_for_visitors
            :examples_table_row
          end
        end
      end
    end
  end
end
