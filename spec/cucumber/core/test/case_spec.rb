require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/platform'
require 'cucumber/core/test/case'

module Cucumber
  module Core
    module Test
      describe Case do
        include Core
        include Core::Gherkin::Writer

        let(:test_case) { Test::Case.new(test_steps, [feature, scenario]) }
        let(:feature) { double }
        let(:scenario) { double }
        let(:test_steps) { [double, double] }

        context 'describing itself' do
          it "describes itself to a visitor" do
            visitor = double
            args = double
            visitor.should_receive(:test_case).with(test_case, args)
            test_case.describe_to(visitor, args)
          end

          it "asks each test_step to describe themselves to the visitor" do
            visitor = double
            args = double
            test_steps.each do |test_step|
              test_step.should_receive(:describe_to).with(visitor, args)
            end
            visitor.stub(:test_case).and_yield
            test_case.describe_to(visitor, args)
          end

          it "describes its source to a visitor" do
            visitor = double
            args = double
            feature.should_receive(:describe_to).with(visitor, args)
            scenario.should_receive(:describe_to).with(visitor, args)
            test_case.describe_source_to(visitor, args)
          end
        end

        describe "#name" do
          context "created from a scenario" do
            it "takes its name from the name of a scenario" do
              gherkin = gherkin do
                feature do
                  scenario 'Scenario name' do
                    step 'passing'
                  end
                end
              end
              receiver = double
              receiver.should_receive(:test_case) do |test_case|
                test_case.name.should == 'Scenario name'
              end
              compile([gherkin], receiver)
            end
          end

          context "created from a scenario outline example" do
            it "takes its name from the name of the scenario outline and examples table" do
              gherkin = gherkin do
                feature do
                  scenario_outline 'outline name' do
                    step 'passing with arg'

                    examples 'examples name' do
                      row 'arg'
                      row 'x'
                    end
                  end
                end
              end
              receiver = double
              receiver.should_receive(:test_case) do |test_case|
                test_case.name.should == 'outline name, examples name (row 1)'
              end
              compile [gherkin], receiver
            end
          end
        end

        describe "#tags" do
          it "includes all tags from the parent feature" do
            gherkin = gherkin do
              feature tags: ['@a', '@b'] do
                scenario tags: ['@c'] do
                  step
                end
                scenario_outline tags: ['@d'] do
                  step 'passing with arg'
                  examples tags: ['@e'] do
                    row 'arg'
                    row 'x'
                  end
                end
              end
            end
            receiver = double
            receiver.should_receive(:test_case) do |test_case|
              test_case.tags.should == ['@a', '@b', '@c']
            end.once.ordered
            receiver.should_receive(:test_case) do |test_case|
              test_case.tags.should == ['@a', '@b', '@d', '@e']
            end.once.ordered
            compile [gherkin], receiver
          end
        end

        describe "#language" do
          it 'takes its language from the feature' do
            gherkin = %{# language: en-pirate
              Ahoy matey!: Treasure map
                Heave to: Find the treasure
                  Gangway!: a map
            }
            receiver = double
            receiver.should_receive(:test_case) do |test_case|
              test_case.language.iso_code.should == 'en-pirate'
            end
            compile([gherkin], receiver)
          end
        end
      end
    end
  end
end
