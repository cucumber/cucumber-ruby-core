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

        attr_reader :line
        private :line

        include Cucumber.initializer(:language, :location, :background, :comments, :tags, :feature_tags, :keyword, :title, :description, :steps, :examples_tables)

        attr_reader :comments, :tags, :keyword, :background, :location

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
