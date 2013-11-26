require 'cucumber/core/test/hook_compiler'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'
require 'cucumber/core/test/runner'
require 'cucumber/core/test/mapper'

module Cucumber::Core::Test
  describe HookCompiler do

    subject(:hook_compiler) { HookCompiler.new(mappings, receiver) }
    let(:mappings)   { double('mappings', test_case: nil) }
    let(:receiver)   { double('receiver', test_case: nil) }
    let(:test_case)  { Case.new([test_step], source) }
    let(:test_step)  { Step.new([double('step', name: 'passing')]) }
    let(:source)     { [feature, scenario] }
    let(:feature)    { double('feature') }
    let(:scenario)   { double('scenario') }

    before do
      expect( receiver ).to receive(:test_case) do |test_case|
        expect( test_case ).to have(1).test_steps
      end
      test_case.describe_to hook_compiler
    end

    it "prepends before hooks to the test case" do
      mappings.stub(:test_case) do |test_case, mapper|
        mapper.before {}
      end
      expect( receiver ).to receive(:test_case) do |test_case|
        expect( test_case ).to have(2).test_steps
      end
      test_case.describe_to hook_compiler
    end

    it "appends after hooks to the test case" do
      mappings.stub(:test_case) do |test_case, mapper|
        mapper.after {}
      end
      expect( receiver ).to receive(:test_case) do |test_case|
        expect( test_case ).to have(2).test_steps
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
        expect( log ).to receive(message).ordered
      end
      runner = Runner.new(double.as_null_object)
      mapper = Mapper.new(mappings, runner)
      hook_compiler = HookCompiler.new(mappings, mapper)
      test_case.describe_to hook_compiler
    end

    it "sets the source on the hook step to be just the hook" do
      test_case = Case.new([], source)
      mappings.stub(:test_case) do |test_case_to_be_mapped, mapper|
        mapper.before {}
      end
      receiver.stub(:test_case).and_yield
      receiver.stub(:test_step) do |test_step|
        expect( receiver ).to receive(:hook)
        test_step.describe_source_to(receiver)
      end
      test_case.describe_to(hook_compiler)
    end

  end
end
