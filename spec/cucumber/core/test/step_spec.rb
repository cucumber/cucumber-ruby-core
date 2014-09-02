require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe Step do
    let(:last_result) { double('last_result') }

    describe "describing itself" do
      it "describes itself to a visitor" do
        visitor = double
        args = double
        test_step = Step.new([double])
        expect( visitor ).to receive(:test_step).with(test_step, args)
        test_step.describe_to(visitor, args)
      end

      it "describes its source to a visitor" do
        feature, scenario, step_or_hook = double, double, double
        visitor = double
        args = double
        expect( feature      ).to receive(:describe_to).with(visitor, args)
        expect( scenario     ).to receive(:describe_to).with(visitor, args)
        expect( step_or_hook ).to receive(:describe_to).with(visitor, args)
        test_step = Step.new([feature, scenario, step_or_hook])
        test_step.describe_source_to(visitor, args)
      end
    end

    describe "executing" do
      let(:ast_step) { double }

      context "when a passing mapping exists" do
        it "returns a passing result" do
          test_step = Step.new([ast_step]).with_mapping {}
          expect( test_step.execute(last_result) ).to be_passed
        end
      end

      context "when a failing mapping exists" do
        let(:exception) { StandardError.new('oops') }

        it "returns a failing result" do
          test_step = Step.new([ast_step]).with_mapping { raise exception }
          result = test_step.execute(last_result)
          expect( result           ).to be_failed
          expect( result.exception ).to eq exception
        end
      end

      context "with no mapping" do
        it "returns an Undefined result" do
          test_step = Step.new([ast_step])
          result = test_step.execute(last_result)
          expect( result           ).to be_undefined
        end
      end
    end

    it "exposes the name and location of the AST step or hook as attributes" do
      name, location = double, double
      step_or_hook = double(name: name, location: location)
      test_step = Step.new([step_or_hook])
      expect( test_step.name     ).to eq name
      expect( test_step.location ).to eq location
    end

  end
end
