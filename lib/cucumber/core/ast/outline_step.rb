# frozen_string_literal: true
require 'cucumber/core/ast/location'
require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/step'

module Cucumber
  module Core
    module Ast

      class OutlineStep
        include HasLocation
        include DescribesItself

        attr_reader :language, :location, :comments, :keyword, :text, :multiline_arg

        def initialize(language, location, comments, keyword, text, multiline_arg)
          @language, @location, @comments, @keyword, @text, @multiline_arg = language, location, comments, keyword, text, multiline_arg
        end

        def to_step(row)
          Ast::ExpandedOutlineStep.new(self, language, row.location, comments, keyword, row.expand(text), replace_multiline_arg(row))
        end

        def to_s
          text
        end

        def inspect
          keyword_and_text = [keyword, text].join(": ")
          %{#<#{self.class} "#{keyword_and_text}" (#{location})>}
        end

        private

        def description_for_visitors
          :outline_step
        end

        def children
          # TODO remove duplication with Step
          # TODO spec
          [@multiline_arg]
        end

        def replace_multiline_arg(example_row)
          return unless multiline_arg
          multiline_arg.map { |cell| example_row.expand(cell) }
        end
      end

    end
  end
end
