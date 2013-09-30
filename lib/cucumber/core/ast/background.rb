require 'cucumber/initializer'
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

        include Cucumber.initializer(:language, :location, :comments, :keyword, :title, :description, :raw_steps)

        attr_accessor :feature
        attr_accessor :comments, :keyword, :location

        def gherkin_statement(node)
          @gherkin_statement = node
        end

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
