require 'cucumber/core/test/mapping'

module Cucumber
  module Core
    module Test

      describe Mapping do

        context "constructed without a block" do
          it "raises an error" do
            expect { Mapping.new }.to raise_error(ArgumentError)
          end
        end

        context "executing" do
          it "executes the block passed to the constructor" do
            executed = false
            mapping = Mapping.new { executed = true }
            mapping.execute
            executed.should == true
          end

          it "returns a passed result if the block doesn't fail" do
            mapping = Mapping.new {}
            mapping.execute.should be_passed
          end

          it "returns a failed result when the block raises an error" do
            exception = StandardError.new
            mapping = Mapping.new { raise exception }
            mapping.execute.should == Result::Failed.new(exception)
          end
        end

        context "skipping" do
          it "does not execute the block" do
            executed = false
            mapping = Mapping.new { executed = true }
            mapping.skip
            executed.should == false
          end

          it "returns a skipped result" do
            mapping = Mapping.new {}
            mapping.skip.should be_skipped
          end
        end
      end

      describe UndefinedMapping do
        let(:mapping) { UndefinedMapping.new }
        let(:test_step) { double }

        context "executing" do
          it "returns an undefined result" do
            mapping.execute.should be_undefined
          end
        end

        context "skipping" do
          it "returns an undefined result" do
            mapping.skip.should be_undefined
          end
        end

      end

    end
  end
end

