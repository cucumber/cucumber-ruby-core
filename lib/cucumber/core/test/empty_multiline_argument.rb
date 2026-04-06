# frozen_string_literal: true

module Cucumber
  module Core
    module Test
      class EmptyMultilineArgument
        def data_table?
          false
        end

        def describe_to(*)
          self
        end

        def doc_string?
          false
        end

        def inspect
          "#<#{self.class}>"
        end

        def lines_count
          0
        end

        def map
          self
        end
      end
    end
  end
end
