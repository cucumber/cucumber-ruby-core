require 'cucumber/core/test/suite_runner'
require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe SuiteRunner do
    describe "executing a test step" do
      let(:runner) { SuiteRunner.new(mappings, report) }
      let(:mappings) { stub }
      let(:report)   { stub.as_null_object }
      let(:ast_step) { stub }

      context "when a passing mapping exists for the step" do
        before do
          mappings.stub(:execute).with(ast_step).and_return(mappings)
        end

        it "returns a passing result" do
          expected_test_step = Step.new([ast_step])
          report.should_receive(:after_test_step) do |test_step, result|
            test_step.should == expected_test_step
            result.should == Result::Passed.new(expected_test_step)
          end
          runner.test_step(expected_test_step)
        end
      end

      context "when a failing mapping exists for the step" do
        let(:exception) { StandardError.new('oops') }

        before do
          mappings.stub(:execute).with(ast_step).and_raise(exception)
        end

        it "returns a failing result" do
          expected_test_step = Step.new([ast_step])
          report.should_receive(:after_test_step) do |test_step, result|
            test_step.should == expected_test_step
            result.should == Result::Failed.new(test_step, exception)
          end
          runner.test_step(expected_test_step)
        end
      end

    end

  end
end
