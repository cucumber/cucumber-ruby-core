require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe Step do

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
