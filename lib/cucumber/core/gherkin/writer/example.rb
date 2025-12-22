# frozen_string_literal: true

require_relative 'helpers'
require_relative 'scenario'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class Example < Scenario
          include Indentation.level 4

          default_keyword 'Example'
        end
      end
    end
  end
end
