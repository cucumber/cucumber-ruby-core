module Cucumber
  module Core
    module Ast
      class EmptyMultilineArgument
        def describe_to(*)
          self
        end

        def map(&block)
          self
        end

        def match_locations?(*args)
          false
        end

        def to_sexp
          []
        end
      end
    end
  end
end

