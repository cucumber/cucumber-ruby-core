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
          end
        end

        context "skipping" do
          it "is a noop" do
            mapping = Mapping.new {}
            mapping.skip.should == mapping
          end
        end
      end
    end
  end
end

