require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/platform'
require 'cucumber/core/test/case'
require 'unindent'

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
                      row '1'
                      row '2'
                    end
                  end
                end
              end
              receiver = double
              receiver.should_receive(:test_case) do |test_case|
                test_case.name.should == 'outline name, examples name (row 1)'
              end.once.ordered
              receiver.should_receive(:test_case) do |test_case|
                test_case.name.should == 'outline name, examples name (row 2)'
              end.once.ordered
              compile [gherkin], receiver
            end
          end
        end

        describe "#location" do
          context "created from a scenario" do
            it "takes its location from the location of the scenario" do
              gherkin = gherkin('features/foo.feature') do
                feature do
                  scenario do
                    step
                  end
                end
              end
              receiver = double
              receiver.should_receive(:test_case) do |test_case|
                test_case.location.to_s.should == 'features/foo.feature:3'
              end
              compile([gherkin], receiver)
            end
          end

          context "created from a scenario outline example" do
            it "takes its location from the location of the scenario outline example row" do
              gherkin = gherkin('features/foo.feature') do
                feature do
                  scenario_outline do
                    step 'passing with arg'

                    examples do
                      row 'arg'
                      row '1'
                      row '2'
                    end
                  end
                end
              end
              receiver = double
              receiver.should_receive(:test_case) do |test_case|
                test_case.location.to_s.should == 'features/foo.feature:8'
              end.once.ordered
              receiver.should_receive(:test_case) do |test_case|
                test_case.location.to_s.should == 'features/foo.feature:9'
              end.once.ordered
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
              test_case.tags.map(&:name).should == ['@a', '@b', '@c']
            end.once.ordered
            receiver.should_receive(:test_case) do |test_case|
              test_case.tags.map(&:name).should == ['@a', '@b', '@d', '@e']
            end.once.ordered
            compile [gherkin], receiver
          end
        end

        describe "matching tags" do
          it "matches boolean expressions of tags" do
            gherkin = gherkin do
              feature tags: ['@a', '@b'] do
                scenario tags: ['@c'] do
                  step
                end
              end
            end
            receiver = double
            receiver.should_receive(:test_case) do |test_case|
              test_case.match_tags?('@a').should be_true
            end
            compile [gherkin], receiver
          end
        end

        describe "#language" do
          it 'takes its language from the feature' do
            gherkin = Gherkin::Document.new('features/treasure.feature', %{# language: en-pirate
              Ahoy matey!: Treasure map
                Heave to: Find the treasure
                  Gangway!: a map
            })
            receiver = double
            receiver.should_receive(:test_case) do |test_case|
              test_case.language.iso_code.should == 'en-pirate'
            end
            compile([gherkin], receiver)
          end
        end

        describe "matching location" do
          let(:file) { 'features/path/to/the.feature' }
          let(:test_cases) do
            receiver = double
            result = []
            receiver.stub(:test_case) { |test_case| result << test_case }
            compile [source], receiver
            result
          end

          context "for a scenario" do
            let(:source) do
              Gherkin::Document.new(file, <<-END.unindent)
                Feature:

                  Scenario: one
                    Given one a

                  # comment
                  @tags
                  Scenario: two
                    Given two a
                    And two b

                  Scenario: three
                    Given three b

                  Scenario: with docstring
                    Given a docstring
                      """
                      this is a docstring
                      """
              END
            end

            let(:test_case) do
              test_cases.find { |c| c.name == 'two' }
            end

            it 'matches the precise location of the scenario' do
              location = Ast::Location.new(file, 8)
              test_case.match_locations?([location]).should be_true
            end

            it 'matches multiple locations' do
              good_location = Ast::Location.new(file, 8)
              bad_location = Ast::Location.new(file, 5)
              test_case.match_locations?([good_location, bad_location]).should be_true
            end

            it 'matches a location on the last step of the scenario' do
              location = Ast::Location.new(file, 10)
              test_case.match_locations?([location]).should be_true
            end

            it "matches a location on the scenario's comment" do
              location = Ast::Location.new(file, 6)
              test_case.match_locations?([location]).should be_true
            end

            it "matches a location on the scenario's tags" do
              location = Ast::Location.new(file, 7)
              test_case.match_locations?([location]).should be_true
            end

            it "doesn't match a location after the last step of the scenario" do
              location = Ast::Location.new(file, 11)
              test_case.match_locations?([location]).should be_false
            end

            it "doesn't match a location before the scenario" do
              location = Ast::Location.new(file, 5)
              test_case.match_locations?([location]).should be_false
            end

            context "with a docstring" do
              let(:test_case) do
                test_cases.find { |c| c.name == 'with docstring' }
              end

              it "matches a location at the start the docstring" do
                location = Ast::Location.new(file, 17)
                test_case.match_locations?([location]).should be_true
              end

              it "matches a location in the middle of the docstring" do
                location = Ast::Location.new(file, 18)
                test_case.match_locations?([location]).should be_true
              end
            end
          end

          context "for a scenario outline" do
            let(:source) do
              Gherkin::Document.new(file, <<-END.unindent)
                Feature: 

                  Scenario: one
                    Given one a

                  # comment on line 6
                  @tags-on-line-7
                  Scenario Outline: two
                    Given two a
                    And two <arg>

                    # comment on line 12
                    @tags-on-line-13
                    Examples: x1
                      | arg |
                      | b   |

                    Examples: x2
                      | arg |
                      | c   |

                  Scenario: three
                    Given three b
              END
            end

            let(:test_case) do
              test_cases.find { |c| c.name == "two, x1 (row 1)" }
            end

            it 'matches the precise location of the scenario outline examples table row' do
              location = Ast::Location.new(file, 16)
              test_case.match_locations?([location]).should be_true
            end

            it 'matches a location on a step of the scenario outline' do
              location = Ast::Location.new(file, 10)
              test_case.match_locations?([location]).should be_true
            end

            it "matches a location on the scenario outline's comment" do
              location = Ast::Location.new(file, 6)
              test_case.match_locations?([location]).should be_true
            end

            it "matches a location on the scenario outline's tags" do
              location = Ast::Location.new(file, 7)
              test_case.match_locations?([location]).should be_true
            end

            it "doesn't match a location after the last row of the examples table" do
              location = Ast::Location.new(file, 17)
              test_case.match_locations?([location]).should be_false
            end

            it "doesn't match a location before the scenario outline" do
              location = Ast::Location.new(file, 5)
              test_case.match_locations?([location]).should be_false
            end
          end
        end
      end
    end
  end
end
