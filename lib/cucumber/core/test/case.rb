require 'cucumber/initializer'
require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test
      class Case
        include Cucumber.initializer(:test_steps, :source, :around_hooks)
        attr_reader :source, :test_steps

        def initialize(test_steps, source, around_hooks = [])
          super(test_steps, source, around_hooks)
        end

        def step_count
          test_steps.count
        end

        def describe_to(visitor, *args)
          visitor.test_case(self, *args) do |child_visitor|
            compose_around_hooks(child_visitor, *args) do
              test_steps.each do |test_step|
                test_step.describe_to(child_visitor, *args)
              end
            end
          end
          self
        end

        def describe_source_to(visitor, *args)
          source.describe_to(visitor, *args)
          self
        end

        def with_steps(test_steps)
          self.class.new(test_steps, source, around_hooks)
        end

        def with_around_hooks(around_hooks)
          self.class.new(test_steps, source, around_hooks)
        end

        def name
          @name ||= NameBuilder.new(self).result
        end

        def tags
          @tags ||= TagCollector.new(self).result
        end

        require 'gherkin/tag_expression'
        def match_tags?(*expressions)
          ::Gherkin::TagExpression.new(expressions.flatten).evaluate(tags.map {|t| ::Gherkin::Formatter::Model::Tag.new(t.name, t.line) })
        end

        def match_name?(name_regexp)
          source.any? { |node| node.respond_to?(:name) && node.name =~ name_regexp }
        end

        def language
          feature.language
        end

        def location
          source.location
        end

        def match_locations?(queried_locations)
          return true if source.any? { |s| s.match_locations?(queried_locations) }
          test_steps.any? { |node| node.match_locations? queried_locations }
        end

        def inspect
          "<#{self.class}: #{location}>"
        end

        def feature
          source.feature
        end

        private

        def compose_around_hooks(visitor, *args, &block)
          around_hooks.reverse.reduce(block) do |continue, hook|
            -> { hook.describe_to(visitor, *args, &continue) }
          end.call
        end

        class NameBuilder
          attr_reader :result

          def initialize(test_case)
            test_case.describe_source_to self
          end

          def feature(*)
            self
          end

          def scenario(scenario)
            @result = "#{scenario.keyword}: #{scenario.name}"
            self
          end

          def scenario_outline(outline)
            @result = "#{outline.keyword}: #{outline.name}" + @result
            self
          end

          def examples_table(table)
            name = table.name.strip
            name = table.keyword if name.length == 0
            @result = ", #{name}" + @result
            self
          end

          def examples_table_row(row)
            @result = " (row #{row.number})"
            self
          end
        end

        class TagCollector
          attr_reader :result

          def initialize(test_case)
            @result = []
            test_case.describe_source_to self
          end

          [:feature, :scenario, :scenario_outline, :examples_table].each do |node_name|
            define_method(node_name) do |node|
              @result = node.tags + @result
              self
            end
          end

          def examples_table_row(*)
          end
        end

      end
    end
  end
end
