module Cucumber
  module Core
    module Ast
      class EmptyBackground
        def describe_to(*)
          self
        end
      end
    end
  end
end

