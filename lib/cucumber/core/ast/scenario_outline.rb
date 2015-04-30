require 'cucumber/core/ast/names'
require 'cucumber/core/ast/location'
require 'cucumber/core/ast/describes_itself'

module Cucumber
  module Core
    module Ast
      class ScenarioOutline
        include Names
        include HasLocation
        include DescribesItself

        MissingExamples = Class.new(StandardError)

        attr_reader :language, :tags, :keyword,
                    :steps, :examples_tables, :line
        private :language, :line

        def initialize(language: "TODO", location:, tags:, keyword:, name:, description: "", steps:, examples:)
          @language          = language
          @location          = location
          @tags              = tags
          @keyword           = keyword
          @name              = name
          @description       = description
          @steps             = steps
          @examples_tables   = examples
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
