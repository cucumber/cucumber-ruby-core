# frozen_string_literal: true

module Cucumber
  module Core
    module Gherkin
      module Writer
        module HasDescription
          private

          def description
            options.fetch(:description, '').split("\n").map(&:strip)
          end

          def description_statement
            description.map { |s| indent(s, 2) } unless description.empty?
          end
        end
      end
    end
  end
end
