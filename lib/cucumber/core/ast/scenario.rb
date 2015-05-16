require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/names'
require 'cucumber/core/ast/empty_background'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      class Scenario
        include Names
        include HasLocation
        include DescribesItself

        attr_reader :gherkin_statement, :language, :location, :background,
                    :comments, :tags, :feature_tags, :keyword,
                    :description, :raw_steps
        private :raw_steps

        def initialize(gherkin_statement, language, location, background, comments, tags, feature_tags, keyword, name, description, raw_steps)
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
          @raw_steps         = raw_steps
        end

        def children
          raw_steps
        end

        def to_sexp
          sexp = [:scenario, line, keyword, name]
          comment = comment.to_sexp
          sexp += [comment] if comment
          tags = tags.to_sexp
          sexp += tags if tags.any?
          sexp += step_invocations.to_sexp if step_invocations.any?
          sexp
        end

        private

        def description_for_visitors
          :scenario
        end
      end
    end
  end
end
