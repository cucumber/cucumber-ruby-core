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

        attr_reader :language, :location, :background,
                    :tags, :keyword,
                    :description, :raw_steps
        private :raw_steps

        def initialize(language: "TODO", location:, tags:, keyword:, name:, description: "", steps:)
          @language          = language
          @location          = location
          @tags              = tags
          @keyword           = keyword
          @name              = name
          @description       = description
          @raw_steps         = steps
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
