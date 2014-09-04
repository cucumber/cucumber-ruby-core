require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      class Step #:nodoc:
        include HasLocation
        include DescribesItself

        attr_reader :keyword, :name, :language, :exception, :multiline_arg, :outline_step

        def initialize(outline_step, language, location, keyword, name, multiline_arg)
          @outline_step, @location, @keyword, @name, @multiline_arg = outline_step, location, keyword, name, multiline_arg
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
