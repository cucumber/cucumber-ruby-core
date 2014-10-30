require 'cucumber/initializer'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'
require 'cucumber/core/source'

module Cucumber
  module Core

    # Compiles the AST into test cases
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

      # @private
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

      # @private
      class FeatureCompiler
        include Cucumber.initializer(:receiver)

        def feature(feature, &descend)
          @feature = feature
          descend.call(self)
          self
        end

        def background(background, &descend)
          source = Source::Background.new(@feature, background)
          compiler = BackgroundCompiler.new(source, receiver)
          descend.call(compiler)
          self
        end

        def scenario(scenario, &descend)
          source = Source::Scenario.new(@feature, scenario)
          scenario_compiler = ScenarioCompiler.new(source, receiver)
          descend.call(scenario_compiler)
          receiver.on_test_case(source)
          self
        end

        def scenario_outline(scenario_outline, &descend)
          source = Source::ScenarioOutline.new(@feature, scenario_outline)
          compiler = ScenarioOutlineCompiler.new(source, receiver)
          descend.call(compiler)
          self
        end
      end

      # @private
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
            receiver.on_step source.with_step(@examples_table, row, step)
          end
          receiver.on_test_case source.with_row(@examples_table, row)
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

      # @private
      class ScenarioCompiler
        include Cucumber.initializer(:source, :receiver)

        def step(step)
          receiver.on_step(source.with_step(step))
          self
        end
      end

      # @private
      class BackgroundCompiler
        include Cucumber.initializer(:source, :receiver)

        def step(step)
          receiver.on_background_step(source.with_step(step))
          self
        end
      end

    end
  end
end
