require 'cucumber/initializer'

module Cucumber
  module Core
    module Gherkin
      class Document
        include Cucumber.initializer(:uri, :body)
        attr_reader :uri, :body

        def to_s
          body
        end

        def ==(other)
          to_s == other.to_s
        end
      end
    end
  end
end
