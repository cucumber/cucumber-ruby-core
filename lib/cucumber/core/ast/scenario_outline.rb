require 'cucumber/core/ast/names'
require 'cucumber/core/ast/location'
require 'cucumber/core/ast/empty_background'
require 'cucumber/core/ast/describes_itself'

module Cucumber
  module Core
    module Ast
      class ScenarioOutline
        include Names
        include HasLocation

        attr_accessor :feature
        attr_reader :feature_tags
        attr_reader :comment, :tags, :keyword, :background

        def initialize(language, location, background, comment, tags, feature_tags, keyword, title, description, steps, examples_tables)
          @language, @location, @background, @comment, @tags, @feature_tags, @keyword, @title, @description, @steps, @examples_tables = language, location, background, comment, tags, feature_tags, keyword, title, description, steps, examples_tables
        end

        def describe_to(visitor)
          visitor.scenario_outline(self) do
            children.each do |child|
              child.describe_to(visitor)
            end
          end
        end

        def children
          @steps + @examples_tables
        end

        def gherkin_statement(node)
          @gherkin_statement = node
        end

        def visit_scenario_name(visitor, row)
          visitor.visit_scenario_name(
            language.keywords('scenario')[0],
            row.name,
            Location.new(file, row.line).to_s,
            source_indent(first_line_length)
          )
        end

        private

        attr_reader :line

        def raise_missing_examples_error
          raise MissingExamples, "Missing Example Section for Scenario Outline at #{@location}"
        end

        MissingExamples = Class.new(StandardError)

        class Step
          include DescribesItself

          attr_reader :name

          def initialize(language, location, keyword, name, multiline_arg=nil)
            @language, @location, @keyword, @name, @multiline_arg = language, location, keyword, name, multiline_arg
            @language || raise("Language is required!")
          end

          attr_reader :gherkin_statement
          def gherkin_statement(statement=nil)
            @gherkin_statement ||= statement
          end

          private

          def description_for_visitors
            :scenario_outline_step
          end

          def children
            []
          end
        end
      end

      class ExamplesTable
        include DescribesItself

        attr_reader :header

        include Cucumber.initializer(:location, :comment, :keyword, :name, :description, :header, :example_rows)

        def gherkin_statement(node)
          @gherkin_statement = node
        end

        private

        def description_for_visitors
          :examples_table
        end

        def children
          [@header] + @example_rows
        end

        class Header
          include DescribesItself

          def initialize(cells)
            @cells = cells
          end

          def ==(other)
            other == @cells
          end

          private

          def description_for_visitors
            :examples_table_header
          end
        end

        class Row
          include DescribesItself

          def initialize(cells)
            @cells = cells
          end

          def ==(other)
            other == @cells
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
