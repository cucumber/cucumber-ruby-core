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

        def to_sexp
          sexp = [:background, line, keyword]
          sexp += [name] unless name.empty?
          comment = comment.to_sexp
          sexp += [comment] if comment
          sexp += steps.to_sexp if steps.any?
          sexp
        end

        # Override this method, as there are situations where the background
        # wind up being the one called fore Before scenarios, and
        # backgrounds don't have tags.
        def source_tags
          []
        end

        def source_tag_names
          source_tags.map { |tag| tag.name }
        end

        private
        def description_for_visitors
          :background
        end

      end
    end
  end
end
