require 'cucumber/core/test/mapper'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber
  module Core
    module Test
      describe Mapper do
        it "maps each of the test steps" do
          defined = Test::Step.new([double(name: 'passing')])
          undefined = Test::Step.new([double(name: 'undefined')])
          source = double('source')
          mappings = double('mappings')
          run_defined_step = false
          mappings.stub(:test_step) do |test_step, mapper|
            if test_step == defined
              mapper.map { run_defined_step = true }
            end
          end
          receiver = double('receiver')
          receiver.should_receive(:test_case) do |test_case|
            visitor = double('visitor')
            visitor.stub(:test_case).and_yield
            visitor.should_receive(:test_step) do |test_step|
              test_step.name.should == 'passing'
            end.once.ordered
            visitor.should_receive(:test_step) do |test_step|
              test_step.name.should == 'undefined'
            end.once.ordered
            test_case.describe_to(visitor)
          end
          Test::Case.new([defined, undefined], source).
            describe_to Mapper.new(mappings, receiver)
        end
      end
    end
  end
end

