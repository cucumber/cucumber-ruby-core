require 'cucumber/initializer'
require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test
      class Case
        include Cucumber.initializer(:test_steps, :source)

        def describe_to(visitor, *args)
          visitor.test_case(self, *args) do |child_visitor=visitor|
            test_steps.each do |test_step|
              test_step.describe_to(child_visitor, *args)
            end
          end
          self
        end

        def describe_source_to(visitor, *args)
          source.each do |node|
            node.describe_to(visitor, *args)
          end
          self
        end

        def with_steps(test_steps)
          self.class.new(test_steps, source)
        end

        def name
          name_builder = NameBuilder.new
          describe_source_to name_builder
          name_builder.result
        end

        def tags
          tag_collector = TagCollector.new
          describe_source_to tag_collector
          tag_collector.result
        end

        def language
          feature.language
        end

        private

        def feature
          source.first
        end

        class NameBuilder
          attr_reader :result

          def feature(*)
          end

          def scenario(scenario)
            @result = scenario.name
          end

          def scenario_outline(outline)
            @result = outline.name
          end

          def examples_table(table)
            @result << ", #{table.name}"
          end

          def examples_table_row(row)
            @result << " (row #{row.number})"
          end
        end

        class TagCollector
          attr_reader :result

          def feature(node)
            @result = node.tags.tags.map(&:name)
          end

          def scenario(node)
            @result += node.tags.tags.map(&:name)
          end

          def scenario_outline(node)
            @result += node.tags.tags.map(&:name)
          end

          def examples_table(node)
            @result += node.tags.tags.map(&:name)
          end

          def examples_table_row(*)
          end
        end

      end
    end
  end
end
