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

        include Cucumber.initializer(:gherkin_statement, :language, :location, :comments, :keyword, :title, :description, :raw_steps)

        attr_accessor :feature
        attr_accessor :comments, :keyword, :location
        attr_reader   :gherkin_statement

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
