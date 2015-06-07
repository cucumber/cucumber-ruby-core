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

        attr_reader :gherkin_statement, :language, :background, :comments,
                    :tags, :feature_tags, :keyword,
                    :steps, :examples_tables, :line
        private :language, :background, :feature_tags, :line

        def initialize(gherkin_statement, language, location, background, comments, tags, feature_tags, keyword, name, description, steps, examples_tables)
          @gherkin_statement = gherkin_statement
          @language          = language
          @location          = location
          @background        = background
          @comments          = comments
          @tags              = tags
          @feature_tags      = feature_tags
          @keyword           = keyword
          @name              = name
          @description       = description
          @steps             = steps
          @examples_tables   = examples_tables
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
