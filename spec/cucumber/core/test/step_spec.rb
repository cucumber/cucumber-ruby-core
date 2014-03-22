require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe Step do

    describe "describing itself" do
      it "describes itself to a visitor" do
        visitor = double
        args = double
        test_step = Step.new([double])
        expect( visitor ).to receive(:test_step).with(test_step, args)
        test_step.describe_to(visitor, args)
      end

      it "describes its source to a visitor" do
        feature, scenario, step = double, double, double
        visitor = double
        args = double
        expect( feature  ).to receive(:describe_to).with(visitor, args)
        expect( scenario ).to receive(:describe_to).with(visitor, args)
        expect( step     ).to receive(:describe_to).with(visitor, args)
        test_step = Step.new([feature, scenario, step])
        test_step.describe_source_to(visitor, args)
      end
    end

    describe "executing a step" do
      let(:ast_step) { double }

      context "when a passing mapping exists for the step" do
        it "returns a passing result" do
          test_step = Step.new([ast_step]).with_mapping {}
          expect( test_step.execute ).to be_passed
        end
      end

      context "when a failing mapping exists for the step" do
        let(:exception) { StandardError.new('oops') }

        it "returns a failing result" do
          test_step = Step.new([ast_step]).with_mapping { raise exception }
          result = test_step.execute
          expect( result           ).to be_failed
          expect( result.exception ).to eq exception
        end
      end
    end

    it "exposes the name and location of the last source node as attributes" do
      name, location = double, double
      ast_step = double(name: name, location: location)
      test_step = Step.new([ast_step])
      expect( test_step.name     ).to eq name
      expect( test_step.location ).to eq location
    end

  end
end
