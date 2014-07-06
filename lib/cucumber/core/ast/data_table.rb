require 'gherkin/rubify'
require 'gherkin/lexer/i18n_lexer'
require 'gherkin/formatter/escaping'
require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      # Step Definitions that match a plain text Step with a multiline argument table
      # will receive it as an instance of DataTable. A DataTable object holds the data of a
      # table parsed from a feature file and lets you access and manipulate the data
      # in different ways.
      #
      # For example:
      #
      #   Given I have:
      #     | a | b |
      #     | c | d |
      #
      # And a matching StepDefinition:
      #
      #   Given /I have:/ do |table|
      #     data = table.raw
      #   end
      #
      # This will store <tt>[['a', 'b'], ['c', 'd']]</tt> in the <tt>data</tt> variable.
      #
      class DataTable
        include DescribesItself
        include HasLocation

        class Builder
          attr_reader :rows

          def initialize
            @rows = []
          end

          def row(row, line_number)
            @rows << row
          end

          def eof
          end
        end

        include ::Gherkin::Rubify

        NULL_CONVERSIONS = Hash.new({ :strict => false, :proc => lambda{ |cell_value| cell_value } }).freeze

        attr_accessor :file

        def self.parse(text, uri, location)
          builder = Builder.new
          lexer = ::Gherkin::Lexer::I18nLexer.new(builder)
          lexer.scan(text)
          new(builder.rows, location)
        end

        # Creates a new instance. +raw+ should be an Array of Array of String
        # or an Array of Hash
        # You don't typically create your own DataTable objects - Cucumber will do
        # it internally and pass them to your Step Definitions.
        #
        def initialize(raw, location)
          @cells_class = Cells
          @cell_class = Cell
          raw = ensure_array_of_array(rubify(raw))
          # Verify that it's square
          raw.transpose
          create_cell_matrix(raw)
          @location = location
        end

        def to_step_definition_arg
          dup
        end

        # Creates a copy of this table
        #
        def dup
          self.class.new(raw.dup, location)
        end

        # Returns a new, transposed table. Example:
        #
        #   | a | 7 | 4 |
        #   | b | 9 | 2 |
        #
        # Gets converted into the following:
        #
        #   | a | b |
        #   | 7 | 9 |
        #   | 4 | 2 |
        #
        def transpose
          self.class.new(raw.transpose, location)
        end

        def map(&block)
          new_raw = raw.map do |row|
            row.map(&block)
          end

          self.class.new(new_raw, location)
        end

        # Converts this table into an Array of Hash where the keys of each
        # Hash are the headers in the table. For example, a DataTable built from
        # the following plain text:
        #
        #   | a | b | sum |
        #   | 2 | 3 | 5   |
        #   | 7 | 9 | 16  |
        #
        # Gets converted into the following:
        #
        #   [{'a' => '2', 'b' => '3', 'sum' => '5'}, {'a' => '7', 'b' => '9', 'sum' => '16'}]
        #
        def hashes
          build_hashes
        end

        # Converts this table into a Hash where the first column is
        # used as keys and the second column is used as values
        #
        #   | a | 2 |
        #   | b | 3 |
        #
        # Gets converted into the following:
        #
        #   {'a' => '2', 'b' => '3'}
        #
        # The table must be exactly two columns wide
        #
        def rows_hash
          verify_table_width(2)
          self.transpose.hashes[0]
        end

        # Gets the raw data of this table. For example, a DataTable built from
        # the following plain text:
        #
        #   | a | b |
        #   | c | d |
        #
        # gets converted into the following:
        #
        #   [['a', 'b'], ['c', 'd']]
        #
        def raw
          cell_matrix.map do |row|
            row.map do |cell|
              cell.value
            end
          end
        end

        def column_names #:nodoc:
          cell_matrix[0].map { |cell| cell.value }
        end

        def rows
          hashes.map do |hash|
            hash.values_at(*headers)
          end
        end

        # For testing only
        def to_sexp #:nodoc:
          [:table, *cells_rows.map{|row| row.to_sexp}]
        end

        def to_hash(cells) #:nodoc:
          hash = Hash.new do |the_hash, key|
            the_hash[key.to_s] if key.is_a?(Symbol)
          end
          column_names.each_with_index do |column_name, column_index|
            hash[column_name] = cells.value(column_index)
          end
          hash
        end

        def verify_table_width(width) #:nodoc:
          raise %{The table must have exactly #{width} columns} unless raw[0].size == width
        end

        def cells_rows #:nodoc:
          cell_matrix.map do |cell_row|
            @cells_class.new(self, cell_row)
          end
        end

        def headers #:nodoc:
          raw.first
        end

        def cell_matrix #:nodoc:
          @cell_matrix
        end

        def col_width(col) #:nodoc:
          columns[col].__send__(:width)
        end

        def each_cell(&proc)
          cell_matrix.each{ |row| row.each(&proc) }
        end

        def ==(other)
          other.class == self.class && raw == other.raw
        end

        def inspect
          raw.inspect
        end

        private

        TO_S_PREFIXES = Hash.new('    ')
        TO_S_PREFIXES[:comment]   = '(+) '
        TO_S_PREFIXES[:undefined] = '(-) '

        def build_hashes
          cells_rows[1..-1].map do |row|
            row.to_hash
          end
        end

        def create_cell_matrix(raw) #:nodoc:
          @cell_matrix = raw.map do |raw_row|
            line = raw_row.line rescue -1
            raw_row.map do |raw_cell|
              new_cell(raw_cell, line)
            end
          end
        end

        def columns #:nodoc:
          cell_matrix.transpose.map do |cell_row|
            @cells_class.new(self, cell_row)
          end
        end

        def new_cell(raw_cell, line) #:nodoc:
          @cell_class.new(raw_cell, self, line)
        end

        def ensure_array_of_array(array)
          Hash === array[0] ? hashes_to_array(array) : array
        end

        def hashes_to_array(hashes) #:nodoc:
          header = hashes[0].keys.sort
          [header] + hashes.map{|hash| header.map{|key| hash[key]}}
        end

        def description_for_visitors
          :data_table
        end

        # Represents a row of cells or columns of cells
        class Cells #:nodoc:
          include Enumerable
          include Gherkin::Formatter::Escaping

          attr_reader :exception

          def initialize(table, cells)
            @table, @cells = table, cells
          end

          # For testing only
          def to_sexp #:nodoc:
            [:row, line, *@cells.map{|cell| cell.to_sexp}]
          end

          def to_hash #:nodoc:
            @to_hash ||= @table.to_hash(self)
          end

          def value(n) #:nodoc:
            self[n].value
          end

          def [](n)
            @cells[n]
          end

          def line
            @cells[0].line
          end

          private

          def width
            map{|cell| cell.value ? escape_cell(cell.value.to_s).unpack('U*').length : 0}.max
          end

          def each(&proc)
            @cells.each(&proc)
          end
        end

        class Cell #:nodoc:
          attr_reader :line, :table
          attr_accessor :status, :value

          def initialize(value, table, line)
            @value, @table, @line = value, table, line
          end

          def inspect!
            @value = "(i) #{value.inspect}"
          end

          def ==(o)
            value == o.value
         end

          # For testing only
          def to_sexp #:nodoc:
            [:cell, @value]
          end
        end
      end
    end
  end
end
