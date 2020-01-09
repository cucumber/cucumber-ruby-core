# This is temporary - we'll use the IDGenerator that built-in cucumber-messages

module Cucumber
  module Core
    module IdGenerator
      class Incrementing
        def initialize
          @index = -1
        end

        def new_id
          @index += 1
          @index.to_s
        end
      end
    end
  end
end