require 'gherkin/rubify'
require 'gherkin/lexer/i18n_lexer'
require 'gherkin/formatter/escaping'
require 'cucumber/core/ast/describes_itself'

module Cucumber
  module Core
    module Ast
      # Step Definitions that match a plain text Step with a multiline argument table
      # will receive it as an instance of Table. A Table object holds the data of a
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
      class Table
        include DescribesItself

        class Different < StandardError
          attr_reader :table

          def initialize(table)
            super('Tables were not identical')
            @table = table
          end
        end

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

        include Enumerable
        include Gherkin::Rubify

        NULL_CONVERSIONS = Hash.new({ :strict => false, :proc => lambda{ |cell_value| cell_value } }).freeze

        attr_accessor :file

        def self.default_arg_name #:nodoc:
          "table"
        end

        def self.parse(text, uri, offset)
          builder = Builder.new
          lexer = Gherkin::Lexer::I18nLexer.new(builder)
          lexer.scan(text)
          new(builder.rows)
        end

        # Creates a new instance. +raw+ should be an Array of Array of String
        # or an Array of Hash (similar to what #hashes returns).
        # You don't typically create your own Table objects - Cucumber will do
        # it internally and pass them to your Step Definitions.
        #
        def initialize(raw, conversion_procs = NULL_CONVERSIONS.dup, header_mappings = {}, header_conversion_proc = nil)
          @cells_class = Cells
          @cell_class = Cell
          raw = ensure_array_of_array(rubify(raw))
          # Verify that it's square
          raw.transpose
          create_cell_matrix(raw)
          @conversion_procs = conversion_procs
          @header_mappings = header_mappings
          @header_conversion_proc = header_conversion_proc
        end

        def to_step_definition_arg
          dup
        end

        # Creates a copy of this table, inheriting any column and header mappings
        # registered with #map_column! and #map_headers!.
        #
        def dup
          self.class.new(raw.dup, @conversion_procs.dup, @header_mappings.dup, @header_conversion_proc)
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
          self.class.new(raw.transpose, @conversion_procs.dup, @header_mappings.dup, @header_conversion_proc)
        end

        # Converts this table into an Array of Hash where the keys of each
        # Hash are the headers in the table. For example, a Table built from
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
        # Use #map_column! to specify how values in a column are converted.
        #
        def hashes
          @hashes ||= build_hashes
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
          return @rows_hash if @rows_hash
          verify_table_width(2)
          @rows_hash = self.transpose.hashes[0]
        end

        # Gets the raw data of this table. For example, a Table built from
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
          @col_names ||= cell_matrix[0].map { |cell| cell.value }
        end

        def rows
          hashes.map do |hash|
            hash.values_at *headers
          end
        end

        def each_cells_row(&proc) #:nodoc:
          cells_rows.each(&proc)
        end

        def accept(visitor) #:nodoc:
          cells_rows.each do |row|
          row.accept(visitor)
        end
        nil
        end

        # Matches +pattern+ against the header row of the table.
        # This is used especially for argument transforms.
        #
        # Example:
        #  | column_1_name | column_2_name |
        #  | x             | y             |
        #
        #  table.match(/table:column_1_name,column_2_name/) #=> non-nil
        #
        # Note: must use 'table:' prefix on match
        def match(pattern)
          header_to_match = "table:#{headers.join(',')}"
          pattern.match(header_to_match)
        end

        # For testing only
        def to_sexp #:nodoc:
          [:table, *cells_rows.map{|row| row.to_sexp}]
        end

        # Redefines the table headers. This makes it possible to use
        # prettier and more flexible header names in the features.  The
        # keys of +mappings+ are Strings or regular expressions
        # (anything that responds to #=== will work) that may match
        # column headings in the table.  The values of +mappings+ are
        # desired names for the columns.
        #
        # Example:
        #
        #   | Phone Number | Address |
        #   | 123456       | xyz     |
        #   | 345678       | abc     |
        #
        # A StepDefinition receiving this table can then map the columns
        # with both Regexp and String:
        #
        #   table.map_headers!(/phone( number)?/i => :phone, 'Address' => :address)
        #   table.hashes
        #   # => [{:phone => '123456', :address => 'xyz'}, {:phone => '345678', :address => 'abc'}]
        #
        # You may also pass in a block if you wish to convert all of the headers:
        #
        #   table.map_headers! { |header| header.downcase }
        #   table.hashes.keys
        #   # => ['phone number', 'address']
        #
        # When a block is passed in along with a hash then the mappings in the hash take precendence:
        #
        #   table.map_headers!('Address' => 'ADDRESS') { |header| header.downcase }
        #   table.hashes.keys
        #   # => ['phone number', 'ADDRESS']
        #
        def map_headers!(mappings={}, &block)
          clear_cache!
          @header_mappings = mappings
          @header_conversion_proc = block
        end

        # Returns a new Table where the headers are redefined. See #map_headers!
        def map_headers(mappings={})
          table = self.dup
          table.map_headers!(mappings)
          table
        end

        # Change how #hashes converts column values. The +column_name+ argument identifies the column
        # and +conversion_proc+ performs the conversion for each cell in that column. If +strict+ is
        # true, an error will be raised if the column named +column_name+ is not found. If +strict+
        # is false, no error will be raised. Example:
        #
        #   Given /^an expense report for (.*) with the following posts:$/ do |table|
        #     posts_table.map_column!('amount') { |a| a.to_i }
        #     posts_table.hashes.each do |post|
        #       # post['amount'] is a Fixnum, rather than a String
        #     end
        #   end
        #
        def map_column!(column_name, strict=true, &conversion_proc)
          @conversion_procs[column_name.to_s] = { :strict => strict, :proc => conversion_proc }
          self
        end

        def to_hash(cells) #:nodoc:
          hash = Hash.new do |hash, key|
            hash[key.to_s] if key.is_a?(Symbol)
          end
          column_names.each_with_index do |column_name, column_index|
            hash[column_name] = cells.value(column_index)
          end
          hash
        end

        def index(cells) #:nodoc:
          cells_rows.index(cells)
        end

        def verify_column(column_name) #:nodoc:
          raise %{The column named "#{column_name}" does not exist} unless raw[0].include?(column_name)
        end

        def verify_table_width(width) #:nodoc:
          raise %{The table must have exactly #{width} columns} unless raw[0].size == width
        end

        def arguments_replaced(arguments) #:nodoc:
          raw_with_replaced_args = raw.map do |row|
          row.map do |cell|
            cell_with_replaced_args = cell
            arguments.each do |name, value|
              if cell_with_replaced_args && cell_with_replaced_args.include?(name)
                cell_with_replaced_args = value ? cell_with_replaced_args.gsub(name, value) : nil
              end
            end
            cell_with_replaced_args
          end
        end
        Table.new(raw_with_replaced_args)
        end

        def has_text?(text) #:nodoc:
          raw.flatten.compact.detect{|cell_value| cell_value.index(text)}
        end

        def cells_rows #:nodoc:
          @rows ||= cell_matrix.map do |cell_row|
          @cells_class.new(self, cell_row)
        end
        end

        def headers #:nodoc:
          raw.first
        end

        def header_cell(col) #:nodoc:
          cells_rows[0][col]
        end

        def cell_matrix #:nodoc:
          @cell_matrix
        end

        def col_width(col) #:nodoc:
          columns[col].__send__(:width)
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

        protected

        def build_hashes
          convert_headers!
          convert_columns!
          cells_rows[1..-1].map do |row|
            row.to_hash
          end
        end

        def inspect_rows(missing_row, inserted_row) #:nodoc:
          missing_row.each_with_index do |missing_cell, col|
          inserted_cell = inserted_row[col]
          if(missing_cell.value != inserted_cell.value && (missing_cell.value.to_s == inserted_cell.value.to_s))
            missing_cell.inspect!
            inserted_cell.inspect!
          end
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

        def convert_columns! #:nodoc:
          @conversion_procs.each do |column_name, conversion_proc|
            verify_column(column_name) if conversion_proc[:strict]
          end

          cell_matrix.transpose.each do |col|
            column_name = col[0].value
            conversion_proc = @conversion_procs[column_name][:proc]
            col[1..-1].each do |cell|
              cell.value = conversion_proc.call(cell.value)
            end
          end
        end

        def convert_headers! #:nodoc:
          header_cells = cell_matrix[0]

          if @header_conversion_proc
            header_values = header_cells.map { |cell| cell.value } - @header_mappings.keys
            @header_mappings = @header_mappings.merge(Hash[*header_values.zip(header_values.map(&@header_conversion_proc)).flatten])
          end

          @header_mappings.each_pair do |pre, post|
            mapped_cells = header_cells.select { |cell| pre === cell.value }
            raise "No headers matched #{pre.inspect}" if mapped_cells.empty?
            raise "#{mapped_cells.length} headers matched #{pre.inspect}: #{mapped_cells.map { |c| c.value }.inspect}" if mapped_cells.length > 1
            mapped_cells[0].value = post
            if @conversion_procs.has_key?(pre)
              @conversion_procs[post] = @conversion_procs.delete(pre)
            end
          end
        end

        def require_diff_lcs #:nodoc:
          begin
            require 'diff/lcs'
          rescue LoadError => e
            e.message << "\n Please gem install diff-lcs\n"
            raise e
          end
        end

        def clear_cache! #:nodoc:
          @hashes = @rows_hash = @col_names = @rows = @columns = nil
        end

        def columns #:nodoc:
            @columns ||= cell_matrix.transpose.map do |cell_row|
            @cells_class.new(self, cell_row)
          end
        end

        def new_cell(raw_cell, line) #:nodoc:
          @cell_class.new(raw_cell, self, line)
        end

        # Pads our own cell_matrix and returns a cell matrix of same
        # column width that can be used for diffing
        def pad!(other_cell_matrix) #:nodoc:
          clear_cache!
          cols = cell_matrix.transpose
          unmapped_cols = other_cell_matrix.transpose

          mapped_cols = []

          cols.each_with_index do |col, col_index|
            header = col[0]
            candidate_cols, unmapped_cols = unmapped_cols.partition do |other_col|
              other_col[0] == header
            end
            raise "More than one column has the header #{header}" if candidate_cols.size > 2

            other_padded_col = if candidate_cols.size == 1
                                 # Found a matching column
                                 candidate_cols[0]
                               else
                                 mark_as_missing(cols[col_index])
                                 (0...other_cell_matrix.length).map do |row|
                                   val = row == 0 ? header.value : nil
                                   SurplusCell.new(val, self, -1)
                                 end
                               end
            mapped_cols.insert(col_index, other_padded_col)
          end

          unmapped_cols.each_with_index do |col, col_index|
            empty_col = (0...cell_matrix.length).map do |row|
              SurplusCell.new(nil, self, -1)
            end
            cols << empty_col
          end

          @cell_matrix = cols.transpose
          (mapped_cols + unmapped_cols).transpose
        end

        def ensure_table(table_or_array) #:nodoc:
          return table_or_array if Table === table_or_array
          Table.new(table_or_array)
        end

        def ensure_array_of_array(array)
          Hash === array[0] ? hashes_to_array(array) : array
        end

        def hashes_to_array(hashes) #:nodoc:
          header = hashes[0].keys.sort
          [header] + hashes.map{|hash| header.map{|key| hash[key]}}
        end

        def ensure_green! #:nodoc:
          each_cell{|cell| cell.status = :passed}
        end

        def each_cell(&proc) #:nodoc:
          cell_matrix.each{|row| row.each(&proc)}
        end

        def mark_as_missing(col) #:nodoc:
          col.each do |cell|
            cell.status = :undefined
          end
        end


        def description_for_visitors
          :table
        end


        # Represents a row of cells or columns of cells
        class Cells #:nodoc:
          include Enumerable
          include Gherkin::Formatter::Escaping

          attr_reader :exception

          def initialize(table, cells)
            @table, @cells = table, cells
          end

          def accept(visitor)
            visitor.visit_table_row(self) do
              each do |cell|
                cell.accept(visitor)
              end
            end
            nil
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

          def dom_id
            "row_#{line}"
          end

          private

          def index
            @table.index(self)
          end

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

          def accept(visitor)
            visitor.visit_table_cell(self) do
              visitor.visit_table_cell_value(value, status)
            end
          end

          def inspect!
            @value = "(i) #{value.inspect}"
          end

          def ==(o)
            SurplusCell === o || value == o.value
          end

          def eql?(o)
            self == o
          end

          def hash
            0
          end

          # For testing only
          def to_sexp #:nodoc:
            [:cell, @value]
          end
        end

        class SurplusCell < Cell #:nodoc:
          def status
            :comment
          end

          def ==(o)
            true
          end

          def hash
            0
          end
        end
      end
    end
  end
end
