require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/step'

module Cucumber
  module Core
    module Ast

      class OutlineStep
        include DescribesItself

        attr_reader :language, :location, :keyword, :name, :multiline_arg

        def initialize(language, location, keyword, name, multiline_arg=nil)
          @language, @location, @keyword, @name, @multiline_arg = language, location, keyword, name, multiline_arg
          @language || raise("Language is required!")
        end

        def gherkin_statement(statement=nil)
          @gherkin_statement ||= statement
        end

        def to_step(row)
          Ast::Step.new(language, location, keyword, row.expand(name), replace_multiline_arg(row))
        end

        private

        def description_for_visitors
          :outline_step
        end

        def children
          # TODO use a null object
          # TODO remove duplication with Step
          # TODO spec
          return [] unless @multiline_arg
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

