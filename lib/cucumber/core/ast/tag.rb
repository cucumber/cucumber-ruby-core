require 'cucumber/initializer'
module Cucumber
  module Core
    module Ast
      class Tag
        include Cucumber.initializer(:location, :name)

        attr_reader :name, :location
      end
    end
  end
end
