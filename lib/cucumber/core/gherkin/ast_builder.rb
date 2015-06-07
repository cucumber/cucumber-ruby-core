require 'cucumber/core/ast'
require 'cucumber/core/platform'
require 'gherkin/rubify'

module Cucumber
  module Core
    module Gherkin
      # Builds an AST of a feature by listening to events from the
      # Gherkin parser.
      class AstBuilder

        def initialize(path)
          @path = path
          @feature_builder = nil
        end

        def result
          return Ast::NullFeature.new unless @feature_builder
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
          @path
        end

        class Builder
          attr_reader :file, :node
          private     :file, :node

          def initialize(file, node)
            @file = file
            @node = node
          end

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
            Ast::Feature.new(
              node,
              language,
              location,
              background,
              comments,
              tags,
              node.keyword,
              node.name.lstrip,
              node.description.rstrip,
              children.map { |builder| builder.result(background, language, tags) }
            )
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
              Ast::Step.new(
                node,
                language,
                location,
                comments,
                node.keyword,
                node.name,
                
                MultilineArgument.from(node.doc_string || node.rows, location)
              )
            end
          end
        end

        class ScenarioOutlineBuilder < Builder
          def result(background, language, feature_tags)
            raise ParseError.new("Missing Examples section for Scenario Outline at #{location}") if examples_builders.empty?
            Ast::ScenarioOutline.new(
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
              steps(language),
              examples_tables(language)
            )
          end

          def add_examples(file, node)
            examples_builders << ExamplesTableBuilder.new(file, node)
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

          def examples_tables(language)
            examples_builders.map { |examples_builder| examples_builder.result(language) }
          end

          def examples_builders
            @examples_builders ||= []
          end

          class ExamplesTableBuilder < Builder

            def result(language)
              Ast::ExamplesTable.new(
                node,
                location,
                comments,
                tags,
                node.keyword,
                node.name,
                node.description,
                header,
                example_rows(language)
              )
            end

            private

            def header
              row = node.rows[0]
              Ast::ExamplesTable::Header.new(row.cells, location, row_comments(row))
            end

            def example_rows(language)
              _, *raw_examples = *node.rows
              raw_examples.each_with_index.map do |row, index|
                header.build_row(row.cells, index + 1, location.on_line(row.line), language, row_comments(row))
              end
            end

            def row_comments(row)
              row.comments.map do |comment|
                Ast::Comment.new(
                  Ast::Location.new(file, comment.line), 
                  comment.value
                )
              end
            end
          end

          class StepBuilder < Builder
            def result(language)
              Ast::OutlineStep.new(
                node,
                language,
                location,
                comments,
                node.keyword,
                node.name,
                MultilineArgument.from(node.doc_string || node.rows, location)
              )
            end
          end
        end

        module MultilineArgument
          class << self
            include ::Gherkin::Rubify

            def from(argument, parent_location)
              return Ast::EmptyMultilineArgument.new unless argument
              argument = rubify(argument)
              case argument
              when ::Gherkin::Formatter::Model::DocString
                Ast::DocString.new(argument.value, argument.content_type, parent_location.on_line(argument.line_range))
              when Array
                location = parent_location.on_line(argument.first.line..argument.last.line)
                Ast::DataTable.new(argument.map{|row| row.cells}, location)
              else
                raise ArgumentError, "Don't know how to convert #{argument.inspect} into a MultilineArgument"
              end
            end
          end
        end

      end
    end
  end
end
