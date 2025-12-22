# frozen_string_literal: true

require_relative 'helpers'

module Cucumber
  module Core
    module Gherkin
      module Writer
        class DocString
          include Indentation.level(6)

          attr_reader :strings, :content_type
          private :strings, :content_type

          def initialize(string, content_type)
            @strings = string.split("\n").map(&:strip)
            @content_type = content_type
          end

          def build(source)
            source + statements
          end

          private

          def statements
            prepare_statements doc_string_statement
          end

          def doc_string_statement
            [
              %("""#{content_type}),
              strings,
              '"""'
            ]
          end
        end
      end
    end
  end
end
