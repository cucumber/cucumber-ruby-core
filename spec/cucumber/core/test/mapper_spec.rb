require 'cucumber/core/test/mapper'
require 'cucumber/core/test/case'
require 'cucumber/core/test/step'
require 'cucumber/core/ast'
require 'cucumber/core/source'

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

        let(:mapper)      { Mapper.new(mappings, receiver) }
        let(:receiver)    { double('receiver') }
        before            { allow(receiver).to receive(:test_case).and_yield(receiver) }
        let(:mappings)    { ExampleMappings.new(app) }
        let(:app)         { double('app') }
        let(:last_result) { double('last_result') }

        context "an unmapped step" do
          let(:test_step) { Test::Step.new(Source::ScenarioStep.new(double, double, double(name: 'unmapped'))) }
          let(:test_case) { Test::Case.new([test_step], double) }

          it "maps to a step that executes to an undefined result" do
            expect( receiver ).to receive(:test_step) do |test_step|
              expect( test_step.name ).to eq 'unmapped'
              expect( test_step.execute(last_result) ).to be_undefined
            end.once.ordered
            test_case.describe_to mapper
          end
        end

        context "a mapped step" do
          let(:test_step) { Test::Step.new(Source::ScenarioStep.new(double, double, double(name: 'mapped'))) }
          let(:test_case) { Test::Case.new([test_step], double) }

          it "maps to a step that executes the block" do
            expect( receiver ).to receive(:test_step) do |test_step|
              expect( test_step.name ).to eq 'mapped'
              expect( app ).to receive(:do_something)
              test_step.execute(last_result)
            end.once.ordered
            test_case.describe_to mapper
          end
        end

        context "a combination" do
          let(:mapped)   { Test::Step.new(Source::ScenarioStep.new(double, double, double(name: 'passing'))) }
          let(:unmapped) { Test::Step.new(Source::ScenarioStep.new(double, double, double(name: 'unmapped'))) }
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

        context "mapping hooks" do
          let(:test_case)  { Case.new([test_step], source) }
          let(:test_step)  { Step.new(Source::ScenarioStep.new(feature, scenario, Ast::Step.new(:node, :language, :location, :keyword, :name, :multiline_arg))) }
          let(:source)     { Source::Scenario.new(feature, scenario) }
          let(:feature)    { Ast::Feature.new(*[double] * 10) }
          let(:scenario)   { Ast::Scenario.new(*[double] * 11) }

          it "prepends before hooks to the test case" do
            allow( mappings ).to receive(:test_case) do |test_case, mapper|
              mapper.before {}
            end
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.step_count ).to eq 2
            end
            test_case.describe_to mapper
          end

          it "appends after hooks to the test case" do
            allow( mappings ).to receive(:test_case) do |test_case, mapper|
              mapper.after {}
            end
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.step_count ).to eq 2
            end
            test_case.describe_to mapper
          end

          it "adds hooks in the right order" do
            log = double
            allow(mappings).to receive(:test_case) do |test_case, mapper|
              mapper.before { log.before_hook_1 }
              mapper.before { log.before_hook_2 }
              mapper.after { log.after_hook_1 }
              mapper.after { log.after_hook_2 }
            end
            mapped_step = test_step.with_mapping { log.step_1 }
            test_case = Case.new([mapped_step], source)

            expect( log ).to receive(:before_hook_1).ordered
            expect( log ).to receive(:before_hook_2).ordered
            expect( log ).to receive(:step_1).ordered
            expect( log ).to receive(:after_hook_2).ordered
            expect( log ).to receive(:after_hook_1).ordered

            allow(receiver).to receive(:test_case).and_yield(receiver)
            allow(receiver).to receive(:test_step) do |test_step|
              test_step.execute(last_result)
            end

            test_case.describe_to mapper
          end

          it "sets the source to include the before hook, scenario and feature" do
            test_case = Case.new([], source)
            allow(mappings).to receive(:test_case) do |test_case_to_be_mapped, mapper|
              mapper.before {}
            end
            allow(receiver).to receive(:test_case).and_yield(receiver)
            allow(receiver).to receive(:test_step) do |test_step|
              args = double('args')
              visitor = double('visitor')
              expect( feature ).to receive(:describe_to)
              expect( scenario ).to receive(:describe_to)
              expect( visitor ).to receive(:before_hook) do |hook, hook_args|
                expect( args ).to eq(hook_args)
                expect( hook.location.to_s ).to eq("#{__FILE__}:126")
              end
              test_step.describe_source_to(visitor, args)
            end
            test_case.describe_to mapper
          end

          it "sets the source to include the after hook" do
            test_case = Case.new([], source)
            allow(mappings).to receive(:test_case) do |test_case_to_be_mapped, mapper|
              mapper.after {}
            end
            allow(receiver).to receive(:test_case).and_yield(receiver)
            allow(receiver).to receive(:test_step) do |test_step|
              expect( test_step.source.hook.location.to_s ).to eq("#{__FILE__}:146")
            end
            test_case.describe_to mapper
          end

          it "appends after_step hooks to the test step" do
            allow(mappings).to receive(:test_step) do |test_step, mapper|
              mapper.after {}
            end
            args = double('args')
            visitor = double('visitor')
            allow(receiver).to receive(:test_case).and_yield(receiver)
            allow(receiver).to receive(:test_step) do |test_step|
              test_step.describe_source_to(visitor, args)
              visitor.next
            end

            expect( visitor ).to receive(:step).ordered
            expect( visitor ).to receive(:scenario).ordered
            expect( visitor ).to receive(:feature).ordered
            expect( visitor ).to receive(:next).ordered

            expect( visitor ).to receive(:after_step_hook) do |hook, hook_args|
              expect( args ).to eq(hook_args)
              expect( hook.location.to_s ).to eq("#{__FILE__}:157")
            end.once.ordered
            expect( visitor ).to receive(:step).ordered
            expect( visitor ).to receive(:scenario).ordered
            expect( visitor ).to receive(:feature).ordered
            expect( visitor ).to receive(:next).ordered
            test_case.describe_to mapper
          end

          it "prepends before_step hooks to the test step" do
            allow(mappings).to receive(:test_step) do |test_step, mapper|
              mapper.before {}
            end
            args = double('args')
            visitor = double('visitor')
            allow(receiver).to receive(:test_case).and_yield(receiver)
            allow(receiver).to receive(:test_step) do |test_step|
              test_step.describe_source_to(visitor, args)
            end
            expect( visitor ).to receive(:before_step_hook) do |hook, hook_args|
              expect( args ).to eq(hook_args)
              expect( hook.location.to_s ).to eq("#{__FILE__}:185")
            end.once.ordered
            expect( visitor ).to receive(:step).ordered
            expect( visitor ).to receive(:scenario).ordered
            expect( visitor ).to receive(:feature).ordered
            expect( visitor ).to receive(:step).ordered
            expect( visitor ).to receive(:scenario).ordered
            expect( visitor ).to receive(:feature).ordered
            test_case.describe_to mapper
          end

        end
      end

    end
  end
end
