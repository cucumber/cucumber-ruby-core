require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe Step do

    describe "describing itself" do
      it "describes itself to a visitor" do
        visitor = double
        args = double
        test_step = Step.new([double])
        visitor.should_receive(:test_step).with(test_step, args)
        test_step.describe_to(visitor, args)
      end

      it "describes its source to a visitor" do
        feature, scenario, step = double, double, double
        visitor = double
        args = double
        feature.should_receive(:describe_to).with(visitor, args)
        scenario.should_receive(:describe_to).with(visitor, args)
        step.should_receive(:describe_to).with(visitor, args)
        test_step = Step.new([feature, scenario, step])
        test_step.describe_source_to(visitor, args)
      end
    end

    describe "executing a step" do
      let(:ast_step) { double }

      context "when a passing mapping exists for the step" do
        it "returns a passing result" do
          expected_test_step = Step.new([ast_step])
          expected_test_step.define {}
          expected_test_step.execute.should == Result::Passed.new(expected_test_step)
        end
      end

      context "when a failing mapping exists for the step" do
        let(:exception) { StandardError.new('oops') }

        it "returns a failing result" do
          expected_test_step = Step.new([ast_step])
          expected_test_step.define { raise exception }
          expected_test_step.execute.should == Result::Failed.new(expected_test_step, exception)
        end
      end
    end

  end
end
