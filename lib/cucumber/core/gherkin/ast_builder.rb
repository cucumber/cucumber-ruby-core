require 'cucumber/initializer'
require 'cucumber/core/ast'
require 'cucumber/core/platform'

module Cucumber
  module Core
    module Gherkin
      # Builds an AST of a feature by listening to events from the
      # Gherkin parser.
      class AstBuilder

        def initialize(path)
          @path = path
        end

        def result
          return nil unless @feature_builder
          @feature_builder.result(language)
        end

        def language=(language)
          @language = language
        end

        def uri(uri)
          @path = uri
        end

        def feature(node)
          @feature_builder = FeatureBuilder.new(file, node)
        end

        def background(node)
          builder = BackgroundBuilder.new(file, node)
          @feature_builder.background_builder = builder
          @current = builder
        end

        def scenario(node)
          builder = ScenarioBuilder.new(file, node)
          @feature_builder.add_child builder
          @current = builder
        end

        def scenario_outline(node)
          builder = ScenarioOutlineBuilder.new(file, node)
          @feature_builder.add_child builder
          @current = builder
        end

        def examples(node)
          @current.add_examples file, node
        end

        def step(node)
          @current.add_step file, node
        end

        def eof
        end

        def syntax_error(state, event, legal_events, line)
          # raise "SYNTAX ERROR"
        end

        private

        def language
          @language || raise("Language has not been set")
        end

        def file
          if Cucumber::WINDOWS && !ENV['CUCUMBER_FORWARD_SLASH_PATHS']
            @path.gsub(/\//, '\\')
          else
            @path
          end
        end

        class Builder
          include Cucumber.initializer(:file, :node)

          private

          def tags
            node.tags.map do |tag|
              Ast::Tag.new(
                Ast::Location.new(file, tag.line),
                tag.name)
            end
          end

          def location
            Ast::Location.new(file, node.line)
          end

          def comments
            node.comments.map do |comment|
              Ast::Comment.new(
                Ast::Location.new(file, comment.line), 
                comment.value
              )
            end
          end
        end

        class FeatureBuilder < Builder
          attr_accessor :background_builder
          private :background_builder

          def initialize(*)
            super
            @background_builder = nil
          end

          def result(language)
            background = background(language)
            feature = Ast::Feature.new(
              location,
              background,
              comments,
              tags,
              node.keyword,
              node.name.lstrip,
              node.description.rstrip,
              children.map { |builder| builder.result(background, language, tags) }
            )
            feature.gherkin_statement(node)
            feature.language = language
            feature
          end

          def add_child(child)
            children << child
          end

          def children
            @children ||= []
          end

          private

          def background(language)
            return Ast::EmptyBackground.new unless background_builder
            @background ||= background_builder.result(language)
          end
        end

        class BackgroundBuilder < Builder
          def result(language)
            Ast::Background.new(
              node,
              language,
              location,
              comments,
              node.keyword,
              node.name,
              node.description,
              steps(language)
            )
          end

          def add_step(file, node)
            step_builders << ScenarioBuilder::StepBuilder.new(file, node)
          end

          private

          def steps(language)
            step_builders.map { |step_builder| step_builder.result(language) }
          end

          def step_builders
            @step_builders ||= []
          end

        end

        class ScenarioBuilder < Builder
          def result(background, language, feature_tags)
            Ast::Scenario.new(
              node,
              language,
              location,
              background,
              comments,
              tags,
              feature_tags,
              node.keyword,
              node.name,
              node.description,
              steps(language)
            )
          end

          def add_step(file, node)
            step_builders << StepBuilder.new(file, node)
          end

          private

          def steps(language)
            step_builders.map { |step_builder| step_builder.result(language) }
          end

          def step_builders
            @step_builders ||= []
          end

          class StepBuilder < Builder
            def result(language)
              step = Ast::Step.new(
                language,
                location,
                node.keyword,
                node.name,
                Ast::MultilineArgument.from(node.doc_string || node.rows, location)
              )
              step.gherkin_statement(node)
              step
            end
          end
        end

        class ScenarioOutlineBuilder < Builder
          def result(background, language, feature_tags)
            scenario_outline = Ast::ScenarioOutline.new(
              language,
              location,
              background,
              comments,
              tags,
              feature_tags,
              node.keyword,
              node.name,
              node.description,
              steps(language),
              examples_tables
            )
            scenario_outline.gherkin_statement(node)
            scenario_outline
          end

          def add_examples(file, node)
            examples_tables << ExamplesTableBuilder.new(file, node).result
          end

          def add_step(file, node)
            step_builders << StepBuilder.new(file, node)
          end

          private

          def steps(language)
            step_builders.map { |step_builder| step_builder.result(language) }
          end

          def step_builders
            @step_builders ||= []
          end

          def examples_tables
            @examples_tables ||= []
          end

          class ExamplesTableBuilder < Builder

            def result
              examples_table = Ast::ExamplesTable.new(
                location,
                comments,
                tags,
                node.keyword,
                node.name,
                node.description,
                header,
                example_rows
              )
              examples_table.gherkin_statement(node)
              examples_table
            end

            private

            def header
              row = node.rows[0]
              Ast::ExamplesTable::Header.new(row.cells, location)
            end

            def example_rows
              _, *raw_examples = *node.rows
              raw_examples.each_with_index.map do |row, index|
                header.build_row(row.cells, index + 1, location.on_line(row.line))
              end
            end

          end

          class StepBuilder < Builder
            def result(language)
              step = Ast::OutlineStep.new(
                language,
                location,
                node.keyword,
                node.name,
                Ast::MultilineArgument.from(node.doc_string || node.rows, location)
              )
              step.gherkin_statement(node)
              step
            end
          end
        end

      end
    end
  end
end
