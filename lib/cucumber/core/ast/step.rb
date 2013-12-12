require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      class Step #:nodoc:
        include HasLocation
        include DescribesItself

        attr_reader :name
        attr_accessor :multiline_arg

        def initialize(language, location, keyword, name, multiline_arg=nil)
          @location, @name, @multiline_arg = location, name, multiline_arg
        end

        def gherkin_statement(statement=nil)
          @gherkin_statement ||= statement
        end

        private

        def children
          return [] unless @multiline_arg # TODO: use a null object
          [@multiline_arg]
        end

        def description_for_visitors
          :step
        end
      end
    end
  end
end
