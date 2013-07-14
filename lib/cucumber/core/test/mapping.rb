module Cucumber
  module Core
    module Test

      class Mapping

        def initialize(&block)
          raise ArgumentError, "Passing a block to execute the mapping is mandatory." unless block
          @block = block
        end

        def skip
          self
        end

        def execute
          @block.call
          self
        end

      end

      class UndefinedMapping < StandardError

        def execute
          raise self
        end

        def skip
          raise self
        end

      end

    end
  end
end
