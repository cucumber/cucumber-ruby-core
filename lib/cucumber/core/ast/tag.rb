require 'cucumber/initializer'
module Cucumber
  module Core
    module Ast
      class Tag
        include HasLocation

        include Cucumber.initializer(:location, :name)

        attr_reader :name
      end
    end
  end
end
