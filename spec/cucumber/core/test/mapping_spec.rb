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
            expect( executed ).to be_truthy
          end

          it "returns a passed result if the block doesn't fail" do
            mapping = Mapping.new {}
            expect( mapping.execute ).to be_passed
          end

          it "returns a failed result when the block raises an error" do
            exception = StandardError.new
            mapping = Mapping.new { raise exception }
            result = mapping.execute
            expect( result ).to be_failed
            expect( result.exception ).to eq exception
          end

          it "returns a pending result if a pending error is raised" do
            exception = Result::Pending.new("TODO")
            mapping = Mapping.new { raise exception }
            result = mapping.execute
            expect( result ).to be_pending
            expect( result.message ).to eq "TODO"
          end

          it "returns a skipped result if a pending error is raised" do
            exception = Result::Skipped.new("Not working right now")
            mapping = Mapping.new { raise exception }
            result = mapping.execute
            expect( result ).to be_skipped
            expect( result.message ).to eq "Not working right now"
          end

          context "recording the duration" do
            before do
              time = double
              allow( Time ).to receive(:now) { time }
              allow( time ).to receive(:nsec).and_return(946752000, 946752001)
              allow( time ).to receive(:to_i).and_return(1377009235, 1377009235)
            end

            it "records the nanoseconds duration of the execution on the result" do
              mapping = Mapping.new { }
              duration = mapping.execute.duration
              expect( duration ).to eq 1
            end

            it "records the duration of a failed execution" do
              mapping = Mapping.new { raise StandardError }
              duration = mapping.execute.duration
              expect( duration ).to eq 1
            end
          end

        end

        context "skipping" do
          it "does not execute the block" do
            executed = false
            mapping = Mapping.new { executed = true }
            mapping.skip
            expect( executed ).to be_falsey
          end

          it "returns a skipped result" do
            mapping = Mapping.new {}
            expect( mapping.skip ).to be_skipped
          end
        end
      end

      describe UndefinedMapping do
        let(:mapping) { UndefinedMapping.new }
        let(:test_step) { double }

        context "executing" do
          it "returns an undefined result" do
            expect( mapping.execute ).to be_undefined
          end
        end

        context "skipping" do
          it "returns an undefined result" do
            expect( mapping.skip ).to be_undefined
          end
        end

      end

    end
  end
end

