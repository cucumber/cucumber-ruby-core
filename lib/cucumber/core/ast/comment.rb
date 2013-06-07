require 'cucumber/initializer'
module Cucumber
  module Core
    module Ast
      # Holds the value of a comment parsed from a feature file:
      #
      #   # Lorem ipsum
      #   # dolor sit amet
      #
      # This gets parsed into a Comment with value <tt>"# Lorem ipsum\n# dolor sit amet\n"</tt>
      #
      class Comment #:nodoc:
        include Cucumber.initializer(:value)

        def empty?
          value.nil? || value == ""
        end

        def accept(visitor)
          return if empty?
          visitor.visit_comment(self) do
            value.strip.split("\n").each do |line|
              visitor.visit_comment_line(line.strip)
            end
          end
        end

        def to_sexp
          (value.nil? || value == '') ? nil : [:comment, value]
        end
      end
    end
  end
end
