require 'cucumber/core/test/mapper'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber
  module Core
    module Test
      describe Mapper do
        let(:mapper)   { Mapper.new(mappings, receiver) }
        let(:receiver) { double('receiver') }
        before         { receiver.stub(:test_case).and_yield }
        let(:mappings) do
          my_app = app
          mappings = double
          mappings.stub(:test_step) do |test_step, mapper|
            mapper.map { my_app.do_something } if test_step.name == 'passing'
          end
          mappings
        end
        let(:app) { double('app') }

        context "an unmapped step" do
          let(:test_step) { Test::Step.new([double(name: 'unmapped')]) }
          let(:test_case) { Test::Case.new([test_step], double) }

          it "maps to a step that executes to an undefined result" do
            receiver.should_receive(:test_step) do |test_step|
              test_step.name.should == 'unmapped'
              test_step.execute.should be_undefined
            end.once.ordered
            test_case.describe_to mapper
          end
        end

        context "a mapped step" do
          let(:test_step) { Test::Step.new([double(name: 'passing')]) }
          let(:test_case) { Test::Case.new([test_step], double) }

          it "maps to a step that executes the block" do
            receiver.should_receive(:test_step) do |test_step|
              test_step.name.should == 'passing'
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

