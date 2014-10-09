require 'cucumber/core/test/action'
require 'cucumber/core/test/duration_matcher'

module Cucumber
  module Core
    module Test

      describe Action do
        let(:last_result) { double('last_result') }

        context "constructed without a block" do
          it "raises an error" do
            expect { Action.new }.to raise_error(ArgumentError)
          end
        end

        context "executing" do
          it "executes the block passed to the constructor" do
            executed = false
            mapping = Action.new { executed = true }
            mapping.execute(last_result)
            expect( executed ).to be_truthy
          end

          it "returns a passed result if the block doesn't fail" do
            mapping = Action.new {}
            expect( mapping.execute(last_result) ).to be_passed
          end

          it "returns a failed result when the block raises an error" do
            exception = StandardError.new
            mapping = Action.new { raise exception }
            result = mapping.execute(last_result)
            expect( result ).to be_failed
            expect( result.exception ).to eq exception
          end

          it "yields the last_result to the block" do
            last_result_spy = nil
            mapping = Action.new { |last_result| last_result_spy = last_result }
            mapping.execute(last_result)
            expect(last_result_spy).to eq last_result
          end

          it "returns a pending result if a Result::Pending error is raised" do
            exception = Result::Pending.new("TODO")
            mapping = Action.new { raise exception }
            result = mapping.execute(last_result)
            expect( result ).to be_pending
            expect( result.message ).to eq "TODO"
          end

          it "returns a skipped result if a Result::Skipped error is raised" do
            exception = Result::Skipped.new("Not working right now")
            mapping = Action.new { raise exception }
            result = mapping.execute(last_result)
            expect( result ).to be_skipped
            expect( result.message ).to eq "Not working right now"
          end

          it "returns an undefined result if a Result::Undefined error is raised" do
            exception = Result::Undefined.new("new step")
            mapping = Action.new { raise exception }
            result = mapping.execute(last_result)
            expect( result ).to be_undefined
            expect( result.message ).to eq "new step"
          end

          context "recording the duration" do
            before do
              time = double
              allow( Time ).to receive(:now) { time }
              allow( time ).to receive(:nsec).and_return(946752000, 946752001)
              allow( time ).to receive(:to_i).and_return(1377009235, 1377009235)
            end

            it "records the nanoseconds duration of the execution on the result" do
              mapping = Action.new { }
              duration = mapping.execute(last_result).duration
              expect( duration ).to be_duration 1
            end

            it "records the duration of a failed execution" do
              mapping = Action.new { raise StandardError }
              duration = mapping.execute(last_result).duration
              expect( duration ).to be_duration 1
            end
          end

        end

        context "skipping" do
          it "does not execute the block" do
            executed = false
            mapping = Action.new { executed = true }
            mapping.skip(last_result)
            expect( executed ).to be_falsey
          end

          it "returns a skipped result" do
            mapping = Action.new {}
            expect( mapping.skip(last_result) ).to be_skipped
          end
        end
      end

      describe UndefinedAction do
        let(:mapping) { UndefinedAction.new }
        let(:test_step) { double }
        let(:last_result) { double('last_result') }

        context "executing" do
          it "returns an undefined result" do
            expect( mapping.execute(last_result) ).to be_undefined
          end
        end

        context "skipping" do
          it "returns an undefined result" do
            expect( mapping.skip(last_result) ).to be_undefined
          end
        end

      end

    end
  end
end

