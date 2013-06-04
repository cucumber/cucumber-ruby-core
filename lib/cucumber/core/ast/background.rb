require 'cucumber/ast/names'
require 'cucumber/ast/location'

module Cucumber
  module Core
    module Ast
      class Background
        include Names
        include HasLocation
        attr_accessor :feature
        attr_accessor :comment, :keyword

        def initialize(language, location, comment, keyword, title, description, raw_steps)
          @language, @location, @comment, @keyword, @title, @description, @raw_steps = language, location, comment, keyword, title, description, raw_steps
        end

        def gherkin_statement(node)
          @gherkin_statement = node
        end

        def describe_to(visitor)
          visitor.background(self) do
            children.each do |child|
              child.describe_to(visitor)
            end
          end
        end

        def children
          []
        end

        def to_sexp
          sexp = [:background, line, @keyword]
          sexp += [name] unless name.empty?
          comment = @comment.to_sexp
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

      end
    end
  end
end
