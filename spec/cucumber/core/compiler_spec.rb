require 'cucumber/core'
require 'cucumber/core/compiler'
require 'cucumber/core/gherkin/writer'

module Cucumber::Core
  describe Compiler do
    include Gherkin::Writer
    include Cucumber::Core

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

    it "compiles a scenario outline to test cases" do
      feature = gherkin do
        feature do
          background do
            step 'passing'
          end

          scenario_outline do
            step 'passing <arg>'
            step 'passing'

            examples do
              row 'arg'
              row '1'
              row '2'
            end

            examples do
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

