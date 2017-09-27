# frozen_string_literal: true
require 'cucumber/core/ast/describes_itself'
require 'cucumber/core/ast/names'
require 'cucumber/core/ast/empty_background'
require 'cucumber/core/ast/location'

module Cucumber
  module Core
    module Ast
      class Scenario
        include Names
        include HasLocation
        include DescribesItself

        attr_reader :location, :background,
                    :comments, :tags, :keyword,
                    :description, :raw_steps
        private :raw_steps

        def initialize(location, comments, tags, keyword, name, description, steps)
          @location          = location
          @comments          = comments
          @tags              = tags
          @keyword           = keyword
          @name              = name
          @description       = description
          @raw_steps         = steps
        end

        def children
          raw_steps
        end

        private

        def description_for_visitors
          :scenario
        end
      end
    end
  end
end
