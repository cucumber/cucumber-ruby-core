require 'cucumber/initializer'
require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/names'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      # Represents the root node of a parsed feature.
      class Feature #:nodoc:
        include Names
        include HasLocation
        include DescribesItself

        attr_accessor :language
        attr_reader :tags

        include Cucumber.initializer(:location, :background, :comments, :tags, :keyword, :title, :description, :feature_elements)
        def initialize(*)
          super
          feature_elements.each { |e| e.feature = self }
        end

        def gherkin_statement(statement=nil)
          @gherkin_statement ||= statement
        end

        def children
          [background] + @feature_elements
        end

        private

        def description_for_visitors
          :feature
        end

      end
    end
  end
end
