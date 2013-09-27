require 'cucumber/initializer'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      class Comment
        include HasLocation
        include Cucumber.initializer :location, :value

        def to_s
          value
        end
      end
    end
  end
end
