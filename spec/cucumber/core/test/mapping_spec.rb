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
            mapping = Mapping.new do
              executed = true
            end
            mapping.execute
            executed.should be_true
          end

          it "raises an error when that's what the block does" do
            mapping = Mapping.new do
              raise StandardError
            end
            expect { mapping.execute }.to raise_error(StandardError)
          end
        end

        context "skipping" do
          it "is a noop" do
            mapping = Mapping.new {}
            mapping.skip.should == mapping
          end
        end
      end

      describe UndefinedMapping do
        let(:mapping) { UndefinedMapping.new }

        context "executing" do
          it "raises UndefinedMapping" do
            expect { mapping.execute }.to raise_error(UndefinedMapping)
          end
        end

        context "skipping" do
          it "raises UndefinedMapping" do
            expect { mapping.skip }.to raise_error(UndefinedMapping)
          end
        end

      end

    end
  end
end

