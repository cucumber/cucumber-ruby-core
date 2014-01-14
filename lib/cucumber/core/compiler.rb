require 'cucumber/initializer'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber
  module Core
    class Compiler
      include Cucumber.initializer(:receiver)

      def feature(feature)
        compiler = FeatureCompiler.new(TestCaseBuilder.new(receiver))
        feature.describe_to(compiler)
        self
      end

      def done
        receiver.done
        self
      end

      class TestCaseBuilder
        include Cucumber.initializer(:receiver)

        def on_background_step(source)
          background_test_steps << Test::Step.new(source)
          self
        end

        def on_step(source)
          test_steps << Test::Step.new(source)
          self
        end

        def on_test_case(source)
          Test::Case.new(test_steps, source).describe_to(receiver)
          @test_steps = nil
          self
        end

        private

        def background_test_steps
          @background_test_steps ||= []
        end

        def test_steps
          @test_steps ||= background_test_steps.dup
        end
      end

      class FeatureCompiler
        include Cucumber.initializer(:receiver)

        def feature(feature, &descend)
          @feature = feature
          descend.call(self)
          self
        end

        def background(background, &descend)
          source = [@feature, background]
          compiler = BackgroundCompiler.new(source, receiver)
          descend.call(compiler)
          self
        end

        def scenario(scenario, &descend)
          source = [@feature, scenario]
          scenario_compiler = ScenarioCompiler.new(source, receiver)
          descend.call(scenario_compiler)
          receiver.on_test_case(source)
          self
        end

        def scenario_outline(scenario_outline, &descend)
          source = [@feature, scenario_outline]
          compiler = ScenarioOutlineCompiler.new(source, receiver)
          descend.call(compiler)
          self
        end
      end

      class ScenarioOutlineCompiler
        include Cucumber.initializer(:source, :receiver)

        def outline_step(outline_step)
          outline_steps << outline_step
          self
        end

        def examples_table(examples_table, &descend)
          @examples_table = examples_table
          descend.call(self)
          self
        end

        def examples_table_row(row)
          steps(row).each do |step|
            receiver.on_step(source + [@examples_table, row, step])
          end
          receiver.on_test_case(source + [@examples_table, row])
          self
        end

        private

        def steps(row)
          outline_steps.map { |s| s.to_step(row) }
        end

        def outline_steps
          @outline_steps ||= []
        end
      end

      class ScenarioCompiler
        include Cucumber.initializer(:source, :receiver)

        def step(step)
          receiver.on_step(source + [step])
          self
        end
      end

      class BackgroundCompiler
        include Cucumber.initializer(:source, :receiver)

        def step(step)
          receiver.on_background_step(source + [step])
          self
        end
      end

    end
  end
end
