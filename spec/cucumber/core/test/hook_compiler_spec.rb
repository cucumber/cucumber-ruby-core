require 'cucumber/core/test/hook_compiler'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'
require 'cucumber/core/test/runner'
require 'cucumber/core/test/mapper'
require 'cucumber/core/ast'

module Cucumber::Core::Test
  describe HookCompiler do

    subject(:hook_compiler) { HookCompiler.new(mappings, receiver) }
    let(:mappings)   { double('mappings', test_case: nil, test_step: nil) }
    let(:receiver)   { double('receiver', test_case: nil) }
    let(:test_case)  { Case.new([test_step], source) }
    let(:test_step)  { Step.new([Cucumber::Core::Ast::Step.new(:language, :location, :keyword, :name, :multiline_arg)]) }
    let(:source)     { [feature, scenario] }
    let(:feature)    { double('feature') }
    let(:scenario)   { double('scenario', location: 'test') }

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
      mapped_step = test_step.with_mapping { log.step }
      test_case = Case.new([mapped_step], source)

      expect( log ).to receive(:before).ordered
      expect( log ).to receive(:step).ordered
      expect( log ).to receive(:after).ordered

      receiver.stub(:test_case) do |*, &continue|
        continue.call
      end

      receiver.stub(:test_step) do |test_step|
        test_step.execute
      end

      hook_compiler = HookCompiler.new(mappings, receiver)
      test_case.describe_to hook_compiler
    end

    it "sets the source to include the before hook" do
      test_case = Case.new([], source)
      mappings.stub(:test_case) do |test_case_to_be_mapped, mapper|
        mapper.before {}
      end
      receiver.stub(:test_case).and_yield
      receiver.stub(:test_step) do |test_step|
        args = double('args')
        visitor = double('visitor')
        expect( visitor ).to receive(:before_hook) do |hook, args|
          expect( args ).to eq(args)
          expect( hook.location.to_s ).to eq("#{__FILE__}:75")
        end
        test_step.describe_source_to(visitor, args)
      end
      test_case.describe_to(hook_compiler)
    end

    it "sets the source to include the after hook" do
      test_case = Case.new([], source)
      mappings.stub(:test_case) do |test_case_to_be_mapped, mapper|
        mapper.after {}
      end
      receiver.stub(:test_case).and_yield
      receiver.stub(:test_step) do |test_step|
        args = double('args')
        visitor = double('visitor')
        expect( visitor ).to receive(:after_hook) do |hook, args|
          expect( args ).to eq(args)
          expect( hook.location.to_s ).to eq("#{__FILE__}:93")
        end
        test_step.describe_source_to(visitor, args)
      end
      test_case.describe_to(hook_compiler)
    end

    it "appends after_step hooks to the test step" do
      mappings.stub(:test_step) do |test_step, mapper|
        mapper.after {}
      end
      args = double('args')
      visitor = double('visitor')
      receiver.stub(:test_case).and_yield
      receiver.stub(:test_step) do |test_step|
        test_step.describe_source_to(visitor, args)
      end
      expect( visitor ).to receive(:step).once.ordered
      expect( visitor ).to receive(:after_step_hook) do |hook, args|
        expect( args ).to eq(args)
        expect( hook.location.to_s ).to eq("#{__FILE__}:110")
      end.once.ordered
      test_case.describe_to(hook_compiler)
    end
  end

  shared_examples_for 'a source node' do
    it "responds to name" do
      expect( subject.name ).to be_a(String)
    end

    it "responds to location" do
      expect( subject.location ).to eq(location)
    end

    it "responds to match_locations?" do
      expect( subject.match_locations? [location] ).to be_true
      expect( subject.match_locations? [] ).to be_false
    end
  end

  require 'cucumber/core/ast/location'
  describe BeforeHook do
    subject { BeforeHook.new(location) }
    let(:location) { Cucumber::Core::Ast::Location.new('hooks.rb', 1) }
    it_behaves_like 'a source node'
  end

  describe AfterHook do
    subject { AfterHook.new(location) }
    let(:location) { Cucumber::Core::Ast::Location.new('hooks.rb', 1) }
    it_behaves_like 'a source node'
  end

end
