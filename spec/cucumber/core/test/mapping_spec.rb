require 'cucumber/core/test/mapping'

module Cucumber
  module Core
    module Test

      describe Mapping do
        let(:test_step) { double }

        context "constructed without a block" do
          it "raises an error" do
            expect { Mapping.new(test_step) }.to raise_error(ArgumentError)
          end
        end

        context "executing" do
          it "executes the block passed to the constructor" do
            executed = false
            mapping = Mapping.new(test_step) { executed = true }
            mapping.execute
            executed.should == true
          end

          it "returns a passed result if the block doesn't fail" do
            mapping = Mapping.new(test_step) {}
            mapping.execute.should == Result::Passed.new(test_step)
          end

          it "returns a failed result when the block raises an error" do
            exception = StandardError.new
            mapping = Mapping.new(test_step) { raise exception }
            mapping.execute.should == Result::Failed.new(test_step, exception)
          end
        end

        context "skipping" do

          it "does not execute the block" do
            executed = false
            mapping = Mapping.new(test_step) { executed = true }
            mapping.skip
            executed.should == false
          end

          it "returns a skipped result" do
            mapping = Mapping.new(test_step) {}
            mapping.skip.should == Result::Skipped.new(test_step)
          end
        end
      end

      describe UndefinedMapping do
        let(:mapping) { UndefinedMapping.new(test_step) }
        let(:test_step) { double }

        context "executing" do
          it "returns and undefined result" do
            mapping.execute.should == Result::Undefined.new(test_step)
          end
        end

        context "skipping" do
          it "raises UndefinedMapping" do
            mapping.skip.should == Result::Undefined.new(test_step)
          end
        end

      end

    end
  end
end

