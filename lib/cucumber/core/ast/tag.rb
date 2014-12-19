module Cucumber
  module Core
    module Ast
      class Tag
        include HasLocation

        attr_reader :name

        def initialize(location, name)
          @location = location
          @name = name
        end
      end
    end
  end
end
