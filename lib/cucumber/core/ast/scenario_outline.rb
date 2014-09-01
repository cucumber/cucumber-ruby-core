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

        attr_reader :feature_tags

        attr_reader :line
        private :line

        include Cucumber.initializer(:gherkin_statement, :language, :location, :background, :comments, :tags, :feature_tags, :keyword, :title, :description, :steps, :examples_tables)

        attr_reader :comments, :tags, :keyword, :background, :location, :gherkin_statement

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
