require 'cucumber/core/test_case'

module Cucumber
  module Core
    module TestCase
      describe Scenario do
        let(:test_case) { TestCase::Scenario.new(test_steps, feature, scenario) }
        let(:feature) { stub }
        let(:scenario) { stub }
        let(:test_steps) { [stub, stub] }

        it "describes itself to a visitor" do
          visitor = stub
          args = stub
          visitor.should_receive(:test_case).with(test_case, args)
          test_case.describe_to(visitor, args)
        end

        it "asks each test_step to describe themselves to the visitor" do
          visitor = stub
          args = stub
          test_steps.each do |test_step|
            test_step.should_receive(:describe_to).with(visitor, args)
          end
          visitor.stub(:test_case).and_yield
          test_case.describe_to(visitor, args)
        end

        it "describes its source to a visitor" do
          visitor = stub
          args = stub
          feature.should_receive(:describe_to).with(visitor, args)
          scenario.should_receive(:describe_to).with(visitor, args)
          test_case.describe_source_to(visitor, args)
        end
      end
    end
  end
end
