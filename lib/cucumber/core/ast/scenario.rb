require 'cucumber/initializer'
require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/names'
require 'cucumber/core/ast/empty_background'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      class Scenario #:nodoc:
        include Names
        include HasLocation
        include DescribesItself

        attr_accessor :feature
        attr_reader :comments, :tags, :location

        include Cucumber.initializer(:language, :location, :background, :comments, :tags, :feature_tags, :keyword, :title, :description, :raw_steps)

        def initialize(*)
          super
          @exception = @executed = nil
        end

        def gherkin_statement(node)
          @gherkin_statement = node
        end

        def children
          raw_steps
        end

        private

        def description_for_visitors
          :scenario
        end

      end
    end
  end
end
