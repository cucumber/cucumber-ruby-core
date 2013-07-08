require 'cucumber/core/test/case'

module Cucumber
  module Core
    module Test
      describe Case do
        let(:test_case) { Test::Case.new(test_steps, [feature, scenario]) }
        let(:feature) { double }
        let(:scenario) { double }
        let(:test_steps) { [double, double] }

        it "describes itself to a visitor" do
          visitor = double
          args = double
          visitor.should_receive(:test_case).with(test_case, args)
          test_case.describe_to(visitor, args)
        end

        it "asks each test_step to describe themselves to the visitor" do
          visitor = double
          args = double
          test_steps.each do |test_step|
            test_step.should_receive(:describe_to).with(visitor, args)
          end
          visitor.stub(:test_case).and_yield
          test_case.describe_to(visitor, args)
        end

        it "describes its source to a visitor" do
          visitor = double
          args = double
          feature.should_receive(:describe_to).with(visitor, args)
          scenario.should_receive(:describe_to).with(visitor, args)
          test_case.describe_source_to(visitor, args)
        end
      end
    end
  end
end
