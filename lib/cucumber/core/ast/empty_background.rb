module Cucumber
  module Core
    module Ast
      class EmptyBackground
        def describe_to(visitor)
        end

        def steps
          []
        end
      end
    end
  end
end

