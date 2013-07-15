# -*- encoding: utf-8 -*-
require 'cucumber/core/test/result'

module Cucumber::Core::Test
  describe Result do

    describe Result::Passed do
      let(:result) { Result::Passed.new }

      it "describes itself to a visitor" do
        visitor = double
        args = double
        visitor.should_receive(:passed).with(args)
        result.describe_to(visitor, args).should == result
      end

      it "converts to a string" do
        result.to_s.should == "✓"
      end
    end

    describe Result::Failed do
      let(:result)    { Result::Failed.new(exception) }
      let(:exception) { StandardError.new("error message") }

      it "describes itself to a visitor" do
        visitor = double
        args = double
        visitor.should_receive(:failed).with(args)
        visitor.should_receive(:exception).with(exception, args)
        result.describe_to(visitor, args).should == result
      end
    end

    describe Result::Unknown do
      let(:result) { Result::Unknown.new }


      it "describes itself to a visitor" do
        visitor = double
        args = double
        result.describe_to(visitor, args).should == result
      end
    end
  end
end
