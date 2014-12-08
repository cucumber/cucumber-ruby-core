module Cucumber
  module Core
    module Source

      def self.new(*node_names, &block)
        Class.new {
          attr_reader :nodes

          def initialize(*nodes)
            @nodes = nodes
          end

          def location
            nodes.last.location
          end

          node_names.each_with_index do |name, index|
            define_method(name) do
              nodes[index]
            end
          end

          def describe_to(visitor, *args)
            nodes.reverse.each do |node|
              node.describe_to(visitor, *args)
            end
          end

          def ==(other)
            @nodes == other.nodes
          end

          def any?(&block)
            @nodes.any?(&block)
          end

          class_exec(&block) if block
        }
      end

      Background = Source.new(:feature, :background) do
        def with_step(step)
          BackgroundStep.new(feature, background, step)
        end
      end

      BackgroundStep = Source.new(:feature, :background, :step)

      Scenario = Source.new(:feature, :scenario) do
        def with_step(step)
          ScenarioStep.new(feature, scenario, step)
        end

        def with_hook(hook)
          ScenarioHook.new(feature, scenario, hook)
        end
      end

      ScenarioStep = Source.new(:feature, :scenario, :step) do
        def with_hook(hook)
          ScenarioStepHook.new(feature, scenario, step, hook)
        end
      end

      ScenarioHook = Source.new(:feature, :scenario, :hook)

      ScenarioStepHook = Source.new(:feature, :scenario, :step, :hook)

      ScenarioOutline = Source.new(:feature, :scenario_outline) do
        def with_step(examples_table, row, step)
          ScenarioOutlineStep.new(feature, scenario_outline, examples_table, row, step)
        end

        def with_row(examples_table, row)
          ScenarioOutlineExamplesTableRow.new(feature, scenario_outline, examples_table, row)
        end
      end

      ScenarioOutlineStep = Source.new(:feature, :scenario_outline, :examples_table, :row, :step)

      ScenarioOutlineExamplesTableRow = Source.new(:feature, :scenario_outline, :examples_table, :row)
    end
  end
end
