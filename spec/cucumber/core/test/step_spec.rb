require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe Step do

    describe "executing" do
      let(:mappings) { stub }
      let(:ast_step) { stub }

      context "when a passing mapping exists for the step" do
        before do
          mappings.stub(:execute).with(ast_step).and_return(mappings)
        end

        it "returns a passing result" do
          test_step = Step.new([ast_step])
          test_step.execute(mappings).should == Result::Passed.new(test_step)
        end
      end

      context "when a failing mapping exists for the step" do
        let(:exception) { StandardError.new('oops') }

        before do
          mappings.stub(:execute).with(ast_step).and_raise(exception)
        end

        it "returns a failing result" do
          test_step = Step.new([ast_step])
          test_step.execute(mappings).should == Result::Failed.new(test_step, exception)
        end
      end

    end

    describe "describing itself" do
      it "describes itself to a visitor" do
        visitor = stub
        args = stub
        test_step = Step.new([stub])
        visitor.should_receive(:test_step).with(test_step, args)
        test_step.describe_to(visitor, args)
      end

      it "describes its source to a visitor" do
        feature, scenario, step = stub, stub, stub
        visitor = stub
        args = stub
        feature.should_receive(:describe_to).with(visitor, args)
        scenario.should_receive(:describe_to).with(visitor, args)
        step.should_receive(:describe_to).with(visitor, args)
        test_step = Step.new([feature, scenario, step])
        test_step.describe_source_to(visitor, args)
      end
    end
  end
end
