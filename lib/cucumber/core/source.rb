module Cucumber
  module Core
    module Source

      module DescribesNodes
        def describe_to(visitor, *args)
          nodes.reverse.each do |node|
            node.describe_to(visitor, *args)
          end
        end
      end

      Background = Struct.new(:feature, :background) do
        def with_step(step)
          BackgroundStep.new(feature, background, step)
        end
      end

      BackgroundStep = Struct.new(:feature, :background, :step)

      Scenario = Struct.new(:feature, :scenario) do
        include DescribesNodes

        def location
          scenario.location
        end

        def with_step(step)
          ScenarioStep.new(feature, scenario, step)
        end

        def with_hook(hook)
          ScenarioHook.new(feature, scenario, hook)
        end

        def nodes
          [feature, scenario]
        end

      end

      ScenarioStep = Struct.new(:feature, :scenario, :step) do
        include DescribesNodes

        def with_hook(hook)
          ScenarioStepHook.new(feature, scenario, step, hook)
        end

        def nodes
          [feature, scenario, step]
        end
      end

      ScenarioHook = Struct.new(:feature, :scenario, :hook) do
        include DescribesNodes

        def nodes
          [feature, scenario, hook]
        end
      end

      ScenarioStepHook = Struct.new(:feature, :scenario, :step, :hook) do
        include DescribesNodes

        def nodes
          [feature, scenario, step, hook]
        end
      end

      ScenarioOutline = Struct.new(:feature, :scenario_outline) do
        def with_step(examples_table, row, step)
          ScenarioOutlineStep.new(feature, scenario_outline, examples_table, row, step)
        end

        def with_row(examples_table, row)
          ScenarioOutlineExamplesTableRow.new(feature, scenario_outline, examples_table, row)
        end
      end

      ScenarioOutlineStep = Struct.new(:feature, :scenario_outline, :examples_table, :row, :step) do
        include DescribesNodes

        def nodes
          [feature, scenario_outline, examples_table, row, step]
        end
      end

      ScenarioOutlineExamplesTableRow = Struct.new(:feature, :scenario_outline, :examples_table, :row) do
        include DescribesNodes

        def location
          row.location
        end

        def nodes
          [feature, scenario_outline, examples_table, row]
        end
      end
    end
  end
end
