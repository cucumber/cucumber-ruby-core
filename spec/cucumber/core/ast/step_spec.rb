require 'cucumber/core/ast/step'

module Cucumber
  module Core
    module Ast
      describe Step do
        let(:step) do
          language, location, keyword, name = *double
          multiline_arg = EmptyMultilineArgument.new
          Step.new(language, location, keyword, name, multiline_arg)
        end

        describe "describing itself" do
          let(:visitor) { double }

          it "describes itself as a step" do
            expect( visitor ).to receive(:step).with(step)
            step.describe_to(visitor)
          end

          context "with no multiline argument" do
            it "does not try to describe any children" do
              visitor.stub(:step).with(step).and_yield(visitor)
              step.describe_to(visitor)
            end
          end

          context "with a multiline argument" do
            let(:step) { Step.new(double, double, double, double, multiline_arg) }
            let(:multiline_arg) { double }

            it "tells its multiline argument to describe itself" do
              visitor.stub(:step).with(step).and_yield(visitor)
              expect( multiline_arg ).to receive(:describe_to).with(visitor)
              step.describe_to(visitor)
            end
          end

        end

      end
    end
  end
end

