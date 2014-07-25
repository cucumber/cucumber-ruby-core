require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      class Step #:nodoc:
        include HasLocation
        include DescribesItself

        attr_reader :keyword, :name, :language, :exception, :multiline_arg

        def initialize(language, location, keyword, name, multiline_arg)
          @location, @keyword, @name, @multiline_arg = location, keyword, name, multiline_arg
        end

        def gherkin_statement(node = nil)
          @gherkin_statement ||= node
        end

        def to_sexp
          [:step, line, keyword, name, @multiline_arg.to_sexp]
        end

        private

        def children
          [@multiline_arg]
        end

        def description_for_visitors
          :step
        end
      end
    end
  end
end
