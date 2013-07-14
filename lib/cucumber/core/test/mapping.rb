module Cucumber
  module Core
    module Test
      class Mapping
        def initialize(&block)
          raise ArgumentError, "Passing a block to execute the mapping is mandatory." unless block
        end
        def skip
          self
        end

        def execute
          self
        end
      end
    end
  end
end
