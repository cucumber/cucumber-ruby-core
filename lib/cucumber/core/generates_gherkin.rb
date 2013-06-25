require 'cucumber/core/generates_gherkin/helpers'

module Cucumber
  module Core
    module GeneratesGherkin
      NEW_LINE = ''
      def gherkin(&source)
        builder = Gherkin.new(&source)
        builder.build
      end

      class Gherkin
        def initialize(&source)
          @source = source
        end

        def feature(*args, &source)
          @feature = Feature.new(*args).tap do |builder|
            builder.instance_exec(&source) if source
          end
          self
        end

        def build
          instance_exec(&@source)
          @feature.build.join("\n")
        end
      end

      class Feature
        include HasElements
        include HasOptionsInitializer
        include Indentation.level(0)

        default_keyword 'Feature'

        elements :background, :scenario, :scenario_outline

        def build(source = [])
          elements.inject(source + statements) { |acc, el| el.build(acc) + [NEW_LINE] }
        end

        private
        def language
          options[:language]
        end

        def statements
          [
            language_statement,
            tag_statement,
            name_statement,
            description_statement,
            NEW_LINE
          ].compact
        end

        def language_statement
          "# language: #{language}" if language
        end

        def description
          options.fetch(:description) { '' }.split("\n").map(&:strip)
        end

        def description_statement
          description.map { |s| indent(s,indent_level+2) } unless description.empty?
        end
      end

      class Background
        include HasElements
        include HasOptionsInitializer
        include Indentation.level 2

        default_keyword 'Background'

        elements :step

        private
        def statements
          prepare_statements tag_statement, name_statement
        end
      end

      class Scenario
        include HasElements
        include HasOptionsInitializer
        include Indentation.level 2

        default_keyword 'Scenario'

        elements :step

        private
        def statements
          prepare_statements tag_statement, name_statement
        end
      end

      class ScenarioOutline
        include HasElements
        include HasOptionsInitializer
        include Indentation.level 2

        default_keyword 'Scenario Outline'

        elements :step, :examples

        private
        def statements
          prepare_statements tag_statement, name_statement
        end
      end

      class Step
        include HasElements
        include HasOptionsInitializer
        include Indentation.level 4

        default_keyword 'Given'

        elements :table

        def doc_string(string)
          elements << DocString.new(string)
        end

        private
        def statements
          prepare_statements name_statement
        end

        def name_statement
          "#{keyword} #{name}"
        end
      end

      class Table
        include Indentation.level(6)
        include HasRows

        def build(source)
          source + statements
        end

        private
        def statements
          row_statements
        end
      end

      class DocString
        include Indentation.level(6)

        attr_reader :strings
        private :strings

        def initialize(string)
          @strings = string.split("\n").map(&:strip)
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
            '"""',
            strings,
            '"""'
          ]
        end
      end

      class Examples
        include HasOptionsInitializer
        include HasRows
        include Indentation.level(4)

        default_keyword 'Examples'

        def build(source)
          source + statements
        end

        private
        def statements
          prepare_statements header_statements, row_statements(2)
        end

        def header_statements
          [
            NEW_LINE,
            tag_statement,
            name_statement
          ]
        end
      end
    end
  end
end
