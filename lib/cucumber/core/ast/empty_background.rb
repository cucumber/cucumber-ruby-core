module Cucumber
  module Core
    module Ast
      class EmptyBackground
        attr_accessor :feature

        def describe_to(*)
          self
        end

        def inspect
          "#<#{self.class.name}>"
        end
      end
    end
  end
end

