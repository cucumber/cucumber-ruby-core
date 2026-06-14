# frozen_string_literal: true

module Cucumber
  module Core
    module Gherkin
      module Writer
        module HasRows
          def row(*cells)
            rows << cells
          end

          def rows
            @rows ||= []
          end

          private

          def row_statements(indent = nil)
            rows.map { |row| indent(table_row(row), indent) }
          end

          def table_row(row)
            padded = pad(row)
            "| #{padded.join(' | ')} |"
          end

          def pad(row)
            row.map.with_index { |text, position| justify_cell(text, position) }
          end

          def column_length(column)
            lengths = rows.transpose.map { |r| r.map(&:length).max }
            lengths[column]
          end

          def justify_cell(cell, position)
            cell.ljust(column_length(position))
          end
        end
      end
    end
  end
end
