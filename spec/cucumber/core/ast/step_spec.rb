require 'cucumber/core/ast/step'

module Cucumber
  module Core
    module Ast
      describe Step do
        let(:step) do
          node, language, location, keyword, name = *double
          multiline_arg = EmptyMultilineArgument.new
          Step.new(node, language, location, keyword, name, multiline_arg)
        end

        describe "describing itself" do
          let(:visitor) { double }

          it "describes itself as a step" do
            expect( visitor ).to receive(:step).with(step)
            step.describe_to(visitor)
          end

          context "with no multiline argument" do
            it "does not try to describe any children" do
              allow( visitor ).to receive(:step).with(step).and_yield(visitor)
              step.describe_to(visitor)
            end
          end

          context "with a multiline argument" do
            let(:step) { Step.new(double, double, double, double, double, multiline_arg) }
            let(:multiline_arg) { double }

            it "tells its multiline argument to describe itself" do
              allow( visitor ).to receive(:step).with(step).and_yield(visitor)
              expect( multiline_arg ).to receive(:describe_to).with(visitor)
              step.describe_to(visitor)
            end
          end

        end

      end

      describe ExpandedOutlineStep do
        let(:outline_step) { double }
        let(:step) do
          node, language, location, keyword, name = *double
          multiline_arg = EmptyMultilineArgument.new
          ExpandedOutlineStep.new(outline_step, node, language, location, keyword, name, multiline_arg)
        end

        describe "describing itself" do
          let(:visitor) { double }

          it "describes itself as a step" do
            expect( visitor ).to receive(:step).with(step)
            step.describe_to(visitor)
          end

          context "with no multiline argument" do
            it "does not try to describe any children" do
              allow( visitor ).to receive(:step).with(step).and_yield(visitor)
              step.describe_to(visitor)
            end
          end

          context "with a multiline argument" do
            let(:step) { Step.new(double, double, double, double, double, multiline_arg) }
            let(:multiline_arg) { double }

            it "tells its multiline argument to describe itself" do
              allow( visitor ).to receive(:step).with(step).and_yield(visitor)
              expect( multiline_arg ).to receive(:describe_to).with(visitor)
              step.describe_to(visitor)
            end
          end

        end

        describe "matching location" do
          let(:location) { double }

          it "also match the outline steps location" do
            allow( location).to receive(:any?).and_return(nil)
            expect( outline_step ).to receive(:match_locations?).with(location)
            step.match_locations?(location)
          end
        end

      end
    end
  end
end

