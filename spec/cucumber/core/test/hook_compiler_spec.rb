require 'cucumber/core/test/hook_compiler'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'

module Cucumber::Core::Test
  describe HookCompiler do

    subject(:hook_compiler) { HookCompiler.new(mappings, receiver) }
    let(:mappings)   { double('mappings', test_case: nil) }
    let(:receiver)   { double('receiver', test_case: nil) }
    let(:test_case)  { Case.new([test_step], [double('scenario')]) }
    let(:test_step)  { Step.new([double('step', name: 'passing')]) }

    before do
      receiver.should_receive(:test_case) do |test_case|
        test_case.should have(1).test_steps
      end
      test_case.describe_to hook_compiler
    end

    it "prepends before hooks to the test case" do
      mappings.stub(:test_case) do |test_case, mapper|
        mapper.before {}
      end
      receiver.should_receive(:test_case) do |test_case|
        test_case.should have(2).test_steps
      end
      test_case.describe_to hook_compiler
    end

    it "appends after hooks to the test case" do
      mappings.stub(:test_case) do |test_case, mapper|
        mapper.after {}
      end
      receiver.should_receive(:test_case) do |test_case|
        test_case.should have(2).test_steps
      end
      test_case.describe_to hook_compiler
    end

    it "adds hooks in the right order" do
      log = double
      mappings.stub(:test_case) do |test_case, mapper|
        mapper.before { log.before }
        mapper.after { log.after }
      end
      mappings.stub(:test_step) do |test_step, mapper|
        mapper.map { log.step }
      end
      [:before, :step, :after].each do |message|
        log.should_receive(message).ordered
      end
      runner = DefaultRunner.new(double.as_null_object)
      mapper = Mapper.new(mappings, runner)
      hook_compiler = HookCompiler.new(mappings, mapper)
      test_case.describe_to hook_compiler
    end

  end
end
