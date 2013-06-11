require 'cucumber/core/result'

module Cucumber
  module Core
    describe Result do

      # the thing that the result is about
      let(:subject) { stub }

      describe Result::Passed do
        let(:result) { Result::Passed.new(subject) }

        it "describes itself to a visitor" do
          visitor = stub
          args = stub
          visitor.should_receive(:passed).with(result, args)
          subject.should_receive(:describe_to).with(visitor, args)
          result.describe_to(visitor, args)
        end

        it "converts to a string" do
          result.to_s.should == "✓"
        end
      end

      describe Result::Failed do
        let(:result)    { Result::Failed.new(subject, exception) }
        let(:exception) { StandardError.new("error message") }

        it "describes itself to a visitor" do
          visitor = stub
          args = stub
          visitor.should_receive(:failed).with(result, args)
          visitor.should_receive(:exception).with(exception, args)
          subject.should_receive(:describe_to).with(visitor, args)
          result.describe_to(visitor, args)
        end
      end

      describe Result::Unknown do
        let(:result) { Result::Unknown.new(subject) }
        it "describes itself to a visitor" do
          visitor = stub
          args = stub
          subject.should_receive(:describe_to).with(visitor, args)
          result.describe_to(visitor, args)
        end
      end
    end
  end
end
