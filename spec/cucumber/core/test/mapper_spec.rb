require 'cucumber/core/test/mapper'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber
  module Core
    module Test
      describe Mapper do

        ExampleMappings = Struct.new(:app) do
          def test_case(test_case, mapper)
          end

          def test_step(test_step, mapper)
            mapper.map { app.do_something } if test_step.name == 'mapped'
          end
        end

        let(:mapper)   { Mapper.new(mappings, receiver) }
        let(:receiver) { double('receiver') }
        before         { receiver.stub(:test_case).and_yield }
        let(:mappings) { ExampleMappings.new(app) }
        let(:app)      { double('app') }

        context "an unmapped step" do
          let(:test_step) { Test::Step.new([double(name: 'unmapped')]) }
          let(:test_case) { Test::Case.new([test_step], double) }

          it "maps to a step that executes to an undefined result" do
            expect( receiver ).to receive(:test_step) do |test_step|
              expect( test_step.name ).to eq 'unmapped'
              expect( test_step.execute ).to be_undefined
            end.once.ordered
            test_case.describe_to mapper
          end
        end

        context "a mapped step" do
          let(:test_step) { Test::Step.new([double(name: 'mapped')]) }
          let(:test_case) { Test::Case.new([test_step], double) }

          it "maps to a step that executes the block" do
            expect( receiver ).to receive(:test_step) do |test_step|
              expect( test_step.name ).to eq 'mapped'
              expect( app ).to receive(:do_something)
              test_step.execute
            end.once.ordered
            test_case.describe_to mapper
          end
        end

        context "a combination" do
          let(:mapped)   { Test::Step.new([double(name: 'passing')]) }
          let(:unmapped) { Test::Step.new([double(name: 'unmapped')]) }
          let(:test_case) { Test::Case.new([mapped, unmapped], double) }

          it "maps each of the test steps" do
            expect( receiver ).to receive(:test_step) do |test_step|
              expect( test_step.name ).to eq 'passing'
            end.once.ordered
            expect( receiver ).to receive(:test_step) do |test_step|
              expect( test_step.name ).to eq 'unmapped'
            end.once.ordered
            test_case.describe_to mapper
          end
        end
      end
    end
  end
end

