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
        attr_reader :feature_elements
        attr_reader :comments, :background, :tags, :keyword, :location, :title

        include Cucumber.initializer(:location, :background, :comments, :tags, :keyword, :title, :description, :feature_elements)
        def initialize(*)
          super
        end

        def gherkin_statement(node = nil)
          @gherkin_statement ||= node
        end

        def children
          [background] + @feature_elements
        end

        def short_name
          first_line = name.split(/\n/)[0]
          if first_line =~ /#{language.keywords('feature')}:(.*)/
            $1.strip
          else
            first_line
          end
        end

        def to_sexp
          sexp = [:feature, file, name]
          comment = @comment.to_sexp
          sexp += [comment] if comment
          tags = @tags.to_sexp
          sexp += tags if tags.any?
          sexp += [@background.to_sexp] if @background
          sexp += @feature_elements.map{|fe| fe.to_sexp}
          sexp
        end

        private

        def description_for_visitors
          :feature
        end

      end
    end
  end
end
