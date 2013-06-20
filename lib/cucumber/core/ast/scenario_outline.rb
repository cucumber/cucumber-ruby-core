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
        include DescribesItself

        MissingExamples = Class.new(StandardError)

        attr_accessor :feature
        attr_reader :feature_tags
        attr_reader :comment, :tags, :keyword, :background

        def initialize(language, location, background, comment, tags, feature_tags, keyword, title, description, steps, examples_tables)
          @language, @location, @background, @comment, @tags, @feature_tags, @keyword, @title, @description, @steps, @examples_tables = language, location, background, comment, tags, feature_tags, keyword, title, description, steps, examples_tables
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
          # TODO: move this into the parser
          raise MissingExamples, "Missing Example Section for Scenario Outline at #{@location}"
        end

        def children
          @steps + @examples_tables
        end

        def description_for_visitors
          :scenario_outline
        end

      end

    end
  end
end
