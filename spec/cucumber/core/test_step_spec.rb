require 'cucumber/core/test_step'

module Cucumber::Core
  describe TestStep do

    describe "executing" do
      let(:mappings) { stub }
      let(:ast_step) { stub }

      context "when a passing mapping exists for the step" do
        before do
          mappings.stub(:execute).with(ast_step).and_return(mappings)
        end

        it "returns a passing result" do
          test_step = TestStep.new([ast_step])
          test_step.execute(mappings).should == Result::Passed.new(test_step)
        end
      end

      context "when a failing mapping exists for the step" do
        before do
          mappings.stub(:execute).with(ast_step).and_raise(StandardError, 'failed')
        end

        it "returns a failing result" do
          test_step = TestStep.new([ast_step])
          test_step.execute(mappings).should == Result::Failed.new(test_step)
        end
      end
    end
  end
end
