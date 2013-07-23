require 'cucumber/core/test/mapper'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber
  module Core
    module Test
      describe Mapper do

        ExampleMappings = Struct.new(:app) do
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
            receiver.should_receive(:test_step) do |test_step|
              test_step.name.should eq('unmapped')
              test_step.execute.should be_undefined
            end.once.ordered
            test_case.describe_to mapper
          end
        end

        context "a mapped step" do
          let(:test_step) { Test::Step.new([double(name: 'mapped')]) }
          let(:test_case) { Test::Case.new([test_step], double) }

          it "maps to a step that executes the block" do
            receiver.should_receive(:test_step) do |test_step|
              test_step.name.should eq('mapped')
              app.should_receive(:do_something)
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
            receiver.should_receive(:test_step) do |test_step|
              test_step.name.should == 'passing'
            end.once.ordered
            receiver.should_receive(:test_step) do |test_step|
              test_step.name.should == 'unmapped'
            end.once.ordered
            test_case.describe_to mapper
          end
        end
      end
    end
  end
end

