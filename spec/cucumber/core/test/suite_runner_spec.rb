require 'cucumber/core/test/suite_runner'
require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe SuiteRunner do

    let(:runner) { SuiteRunner.new(mappings, report) }
    let(:mappings) { stub }
    let(:report)   { stub.as_null_object }

    describe "running a suite" do
      it "calls the report before running the suite" do
        suite = stub
        report.should_receive(:before_test_suite).with(suite)
        runner.test_suite(suite) {}
      end

      it "calls the report after running the suite" do
        suite = stub
        report.should_receive(:after_test_suite) do |suite, result|
          suite.should == suite
          result.should == 'TODO: what can we say about the result here?'
        end
        runner.test_suite(suite) {}
      end
    end

    describe "executing a test step" do
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
