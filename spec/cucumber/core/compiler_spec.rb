require 'cucumber/core'
require 'cucumber/core/compiler'
require 'cucumber/core/gherkin/writer'

module Cucumber::Core
  describe Compiler do
    include Gherkin::Writer
    include Cucumber::Core

    def self.stubs(*names)
      names.each do |name|
        let(name) { stub(name.to_s) }
      end
    end

    it "compiles a feature with a single scenario" do
      feature = parse_gherkin(
        gherkin do
          feature do
            scenario do
              step 'passing'
            end
          end
        end
      )

      suite = compile([feature])
      visit(suite) do |visitor|
        visitor.should_receive(:test_case).exactly(1).times.and_yield
        visitor.should_receive(:test_step).exactly(1).times
      end
    end

    it "compiles a feature with a background" do
      feature = parse_gherkin(
        gherkin do
          feature do
            background do
              step 'passing'
            end

            scenario do
              step 'passing'
            end
          end
        end
      )

      suite = compile([feature])
      visit(suite) do |visitor|
        visitor.should_receive(:test_case).exactly(1).times.and_yield
        visitor.should_receive(:test_step).exactly(2).times
      end
    end

    it "compiles multiple features" do
      features = [
        gherkin do
          feature do
            scenario do
              step 'passing'
            end
          end
        end,
        gherkin do
          feature do
            scenario do
              step 'passing'
            end
          end
        end
      ]

      ast = features.map { |f| parse_gherkin(f) }
      suite = compile(ast)
      visit(suite) do |visitor|
        visitor.should_receive(:test_case).exactly(2).times.and_yield
        visitor.should_receive(:test_step).exactly(2).times
      end
    end

    context "compiling scenario outlines" do
      it "compiles a scenario outline to test cases" do
        feature = gherkin do
          feature do
            background do
              step 'passing'
            end

            scenario_outline do
              step 'passing <arg>'
              step 'passing'

              examples 'examples 1' do
                row 'arg'
                row '1'
                row '2'
              end

              examples 'examples 2' do
                row 'arg'
                row 'a'
              end
            end
          end
        end
        suite = compile([parse_gherkin(feature)])
        visit(suite) do |visitor|
          visitor.should_receive(:test_case).exactly(3).times.and_yield
          visitor.should_receive(:test_step).exactly(9).times
        end
      end

      it 'replaces arguments correctly when generating test steps' do
        feature = gherkin do
          feature do
            scenario_outline do
              step 'passing <arg1> with <arg2>'
              step 'as well as <arg3>'

              examples do
                row 'arg1', 'arg2', 'arg3'
                row '1',    '2',    '3'
              end
            end
          end
        end
        suite = compile([parse_gherkin(feature)])

        visit(suite) do |visitor|
          visitor.should_receive(:test_step) do |test_step|
            visit_source(test_step) do |source_visitor|
              source_visitor.should_receive(:step) do |step|
                step.name.should == 'passing 1 with 2'
              end
            end
          end.once.ordered

          visitor.should_receive(:test_step) do |test_step|
            visit_source(test_step) do |source_visitor|
              source_visitor.should_receive(:step) do |step|
                step.name.should == 'as well as 3'
              end
            end
          end.once.ordered
        end
      end
    end

    describe Compiler::FeatureCompiler do
      let(:receiver) { stub('receiver') }
      let(:compiler) { Compiler::FeatureCompiler.new(receiver) }

      context "a scenario with a background" do
        stubs(:feature,
                :background,
                  :background_step,
                :scenario,
                  :scenario_step)

        it "sets the source correctly on the test steps" do
          receiver.should_receive(:background_test_step).with(
            [feature, background, background_step]
          )
          receiver.should_receive(:test_step).with(
            [feature, scenario, scenario_step]
          )
          receiver.should_receive(:test_case).with(
            [feature, scenario]
          )
          compiler.feature(feature) do |compiler|
            compiler.background(background) do |compiler|
              compiler.step background_step
            end
            compiler.scenario(scenario) do |compiler|
              compiler.step scenario_step
            end
          end
        end
      end

      context "a scenario outline" do
        stubs(:feature,
                :background,
                  :background_step,
                :scenario_outline,
                  :outline_step,
                  :examples_table_1,
                    :examples_table_1_row_1,
                      :outline_ast_step,
                  :examples_table_2,
                    :examples_table_2_row_1,
                      :outline_ast_step,
             )

        it "sets the source correctly on the test steps" do
          outline_step.stub(to_step: outline_ast_step)
          receiver.should_receive(:test_step).with(
            [feature, scenario_outline, examples_table_1, examples_table_1_row_1, outline_ast_step]
          ).ordered
          receiver.should_receive(:test_case).with(
            [feature, scenario_outline, examples_table_1, examples_table_1_row_1]
          ).ordered
          receiver.should_receive(:test_step).with(
            [feature, scenario_outline, examples_table_2, examples_table_2_row_1, outline_ast_step]
          ).ordered
          receiver.should_receive(:test_case).with(
            [feature, scenario_outline, examples_table_2, examples_table_2_row_1]
          ).ordered
          compiler.feature(feature) do |compiler|
            compiler.scenario_outline(scenario_outline) do |compiler|
              compiler.outline_step outline_step
              compiler.examples_table(examples_table_1) do |compiler|
                compiler.examples_table_row(examples_table_1_row_1)
              end
              compiler.examples_table(examples_table_2) do |compiler|
                compiler.examples_table_row(examples_table_2_row_1)
              end
            end
          end
        end
      end
    end

    def visit_source(node)
      visitor = stub.as_null_object
      yield visitor
      node.describe_source_to(visitor)
    end

    def visit(suite)
      visitor = stub
      visitor.stub(:test_suite).and_yield
      visitor.stub(:test_case).and_yield
      yield visitor
      suite.describe_to(visitor)
    end

  end
end

