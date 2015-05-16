require 'cucumber/core/ast/names'
require 'cucumber/core/ast/location'
require 'cucumber/core/ast/describes_itself'

module Cucumber
  module Core
    module Ast
      class Background
        include Names
        include HasLocation
        include DescribesItself

        def initialize(gherkin_statement, language, location, comments, keyword, name, description, raw_steps)
          @gherkin_statement = gherkin_statement
          @language = language
          @location = location
          @comments = comments
          @keyword = keyword
          @name = name
          @description = description
          @raw_steps = raw_steps
        end

        attr_reader :language, :description, :raw_steps
        private     :language, :raw_steps

        attr_reader :comments, :keyword, :location
        attr_reader :gherkin_statement

        def children
          raw_steps
        end

        private

        def description_for_visitors
          :background
        end

      end
    end
  end
end
