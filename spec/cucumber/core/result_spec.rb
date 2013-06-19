# -*- encoding: utf-8 -*-
require 'cucumber/core/result'

module Cucumber
  module Core
    describe Result do

      # the thing that the result is about
      let(:subject) { stub }

      describe Result::Passed do
        let(:result) { Result::Passed.new(subject) }

        it "exposes subject as an attribute" do
          result.subject.should == subject
        end

        it "describes itself to a visitor" do
          visitor = stub
          args = stub
          visitor.should_receive(:passed).with(result, args)
          result.describe_to(visitor, args)
        end

        it "converts to a string" do
          result.to_s.should == "✓"
        end

        it "is equal to another result for the same subject" do
          result.should eq(Result::Passed.new(subject))
        end

        it "is not equal to another result for a different subject" do
          result.should_not eq(Result::Passed.new(stub))
        end
      end

      describe Result::Failed do
        let(:result)    { Result::Failed.new(subject, exception) }
        let(:exception) { StandardError.new("error message") }

        it "exposes subject as an attribute" do
          result.subject.should == subject
        end

        it "describes itself to a visitor" do
          visitor = stub
          args = stub
          visitor.should_receive(:failed).with(result, exception, args)
          result.describe_to(visitor, args)
        end

        it "is equal to another result for the same subject and exception" do
          result.should eq(Result::Failed.new(subject, exception))
        end

        it "is not equal to another result for a different subject" do
          result.should_not eq(Result::Failed.new(stub, exception))
        end

        it "is not equal to another result for a different exception" do
          result.should_not eq(Result::Failed.new(subject, stub))
        end
      end

      describe Result::Unknown do
        let(:result) { Result::Unknown.new(subject) }

        it "exposes subject as an attribute" do
          result.subject.should == subject
        end

        it "describes itself to a visitor" do
          visitor = stub
          args = stub
          result.describe_to(visitor, args)
        end

        it "is equal to another result for the same subject" do
          result.should eq(Result::Unknown.new(subject))
        end

        it "is not equal to another result for a different subject" do
          result.should_not eq(Result::Unknown.new(stub))
        end
      end
    end
  end
end
