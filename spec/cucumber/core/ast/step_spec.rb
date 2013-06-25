require 'cucumber/core/ast/step'

module Cucumber
  module Core
    module Ast
      describe Step do
        let(:step) do
          language, location, keyword, name = stub, stub, stub, stub
          Step.new(language, location, keyword, name)
        end

        describe "describing itself" do
          let(:visitor) { stub }

          it "describes itself as a step" do
            visitor.should_receive(:step).with(step)
            step.describe_to(visitor)
          end

          context "with no multiline argument" do
            it "does not try to describe any children" do
              visitor.stub(:step).with(step).and_yield
              step.describe_to(visitor)
            end
          end

          context "with a multiline argument" do
            let(:step) { Step.new(stub, stub, stub, stub, multiline_arg) }
            let(:multiline_arg) { stub }

            it "tells its multiline argument to describe itself" do
              visitor.stub(:step).with(step).and_yield
              multiline_arg.should_receive(:describe_to).with(visitor)
              step.describe_to(visitor)
            end
          end

        end

      end
    end
  end
end

