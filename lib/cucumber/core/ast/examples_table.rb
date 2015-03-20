require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/location'
require 'cucumber/core/ast/names'

module Cucumber
  module Core
    module Ast

      class ExamplesTable
        include Names
        include HasLocation
        include DescribesItself

        def initialize(gherkin_statement, location, comments, tags, keyword, title, description, header, example_rows)
          @gherkin_statement = gherkin_statement
          @location = location
          @comments = comments
          @tags = tags
          @keyword = keyword
          @title = title
          @description = description
          @header = header
          @example_rows = example_rows
        end

        attr_reader :gherkin_statement, :location, :comments, :tags, :keyword,
                    :title, :description, :header, :example_rows
        private :title, :description, :example_rows

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

          def build_row(row_cells, number, location, language)
            Row.new(Hash[@cells.zip(row_cells)], number, location, language)
          end

          def inspect
            "#<#{self.class} #{values} (#{location})>"
          end
        end

        class Row
          include DescribesItself
          include HasLocation

          attr_reader :number, :language

          def initialize(data, number, location, language)
            raise ArgumentError, data.to_s unless data.is_a?(Hash)
            @data = data
            @number = number
            @location = location
            @language = language
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
            "#<#{self.class}: #{@data.inspect} (#{location})>"
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
