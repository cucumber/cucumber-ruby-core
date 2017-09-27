# frozen_string_literal: true
# -*- coding: utf-8 -*-
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
        let(:feature) { double(location: "features/test.feature:1") }
        let(:scenario) { double(location: "features/test.feature:2") }
        let(:test_steps) { [double, double] }

        context 'describing itself' do
          it "describes itself to a visitor" do
            visitor = double
            args = double
            expect( visitor ).to receive(:test_case).with(test_case, args)
            test_case.describe_to(visitor, args)
          end

          it "asks each test_step to describe themselves to the visitor" do
            visitor = double
            args = double
            test_steps.each do |test_step|
              expect( test_step ).to receive(:describe_to).with(visitor, args)
            end
            allow( visitor ).to receive(:test_case).and_yield(visitor)
            test_case.describe_to(visitor, args)
          end

          it "describes around hooks in order" do
            visitor = double
            allow( visitor ).to receive(:test_case).and_yield(visitor)
            first_hook, second_hook = double, double
            expect( first_hook ).to receive(:describe_to).ordered.and_yield
            expect( second_hook ).to receive(:describe_to).ordered.and_yield
            around_hooks = [first_hook, second_hook]
            Test::Case.new([], [], around_hooks).describe_to(visitor, double)
          end

          it "describes its source to a visitor" do
            visitor = double
            args = double
            expect( feature ).to receive(:describe_to).with(visitor, args)
            expect( scenario ).to receive(:describe_to).with(visitor, args)
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
              receiver = double.as_null_object

              expect( receiver ).to receive(:test_case) do |test_case|
                expect( test_case.name ).to eq 'Scenario name'
                expect( test_case.keyword ).to eq 'Scenario'
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
                      row 'a'
                      row 'b'
                    end

                    examples '' do
                      row 'arg'
                      row 'c'
                    end
                  end
                end
              end
              receiver = double.as_null_object
              expect( receiver ).to receive(:test_case) do |test_case|
                expect( test_case.name ).to eq 'outline name, examples name (#1)'
                expect( test_case.keyword ).to eq 'Scenario Outline'
              end.once.ordered
              expect( receiver ).to receive(:test_case) do |test_case|
                expect( test_case.name ).to eq 'outline name, examples name (#2)'
              end.once.ordered
              expect( receiver ).to receive(:test_case) do |test_case|
                expect( test_case.name ).to eq 'outline name, Examples (#1)'
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
              receiver = double.as_null_object
              expect( receiver ).to receive(:test_case) do |test_case|
                expect( test_case.location.to_s ).to eq 'features/foo.feature:3'
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
              receiver = double.as_null_object
              expect( receiver ).to receive(:test_case) do |test_case|
                expect( test_case.location.to_s ).to eq 'features/foo.feature:8'
              end.once.ordered
              expect( receiver ).to receive(:test_case) do |test_case|
                expect( test_case.location.to_s ).to eq 'features/foo.feature:9'
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
            receiver = double.as_null_object
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.tags.map(&:name) ).to eq ['@a', '@b', '@c']
            end.once.ordered
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.tags.map(&:name) ).to eq ['@a', '@b', '@d', '@e']
            end.once.ordered
            compile [gherkin], receiver
          end
        end

        describe "matching tags" do
          it "matches tags using tag expressions" do
            gherkin = gherkin do
              feature tags: ['@a', '@b'] do
                scenario tags: ['@c'] do
                  step
                end
              end
            end
            receiver = double.as_null_object
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.match_tags?(['@a and @b']) ).to be_truthy
              expect( test_case.match_tags?(['@a or @d']) ).to be_truthy
              expect( test_case.match_tags?(['not @d']) ).to be_truthy
              expect( test_case.match_tags?(['@a and @d']) ).to be_falsy
            end
            compile [gherkin], receiver
          end

          it "matches handles multiple expressions" do
            gherkin = gherkin do
              feature tags: ['@a', '@b'] do
                scenario tags: ['@c'] do
                  step
                end
              end
            end
            receiver = double.as_null_object
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.match_tags?(['@a and @b', 'not @d']) ).to be_truthy
              expect( test_case.match_tags?(['@a and @b', 'not @c']) ).to be_falsy
            end
            compile [gherkin], receiver
          end
        end

        describe "matching tags (old style)" do
          it "matches boolean expressions of tags" do
            gherkin = gherkin do
              feature tags: ['@a', '@b'] do
                scenario tags: ['@c'] do
                  step
                end
              end
            end
            receiver = double.as_null_object
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.match_tags?(['@a', '@b']) ).to be_truthy
              expect( test_case.match_tags?(['@a, @d']) ).to be_truthy
              expect( test_case.match_tags?(['~@d']) ).to be_truthy
              expect( test_case.match_tags?(['@a', '@d']) ).to be_falsy
            end
            compile [gherkin], receiver
          end

          it "handles mixing old and new style expressions" do
            gherkin = gherkin do
              feature tags: ['@a', '@b'] do
                scenario tags: ['@c'] do
                  step
                end
              end
            end
            receiver = double.as_null_object
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.match_tags?(['@a and @b', '~@d']) ).to be_truthy
            end
            compile [gherkin], receiver
          end
        end

        describe "matching names" do
          it "matches names against regexp" do
            gherkin = gherkin do
              feature 'first feature' do
                scenario 'scenario' do
                  step 'missing'
                end
              end
            end
            receiver = double.as_null_object
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.match_name?(/feature/) ).to be_truthy
            end
            compile [gherkin], receiver
          end
        end

        describe "#language" do
          it 'takes its language from the feature' do
            gherkin = Gherkin::Document.new('features/treasure.feature', %{# language: en-pirate
              Ahoy matey!: Treasure map
                Heave to: Find the treasure
                  Gangway! a map
            })
            receiver = double.as_null_object
            expect( receiver ).to receive(:test_case) do |test_case|
              expect( test_case.language.iso_code ).to eq 'en-pirate'
            end
            compile([gherkin], receiver)
          end
        end

        describe "equality" do
          it "is equal to another test case at the same location" do
            gherkin = gherkin('features/foo.feature') do
              feature do
                scenario do
                  step
                end
              end
            end
            test_case_instances = []
            receiver = double.as_null_object
            allow(receiver).to receive(:test_case) do |test_case|
              test_case_instances << test_case
            end
            2.times { compile([gherkin], receiver) }
            expect(test_case_instances.length).to eq 2
            expect(test_case_instances.uniq.length).to eq 1
            expect(test_case_instances[0]).to be_eql test_case_instances[1]
            expect(test_case_instances[0]).to eq test_case_instances[1]
            expect(test_case_instances[0]).not_to equal test_case_instances[1]
          end
        end

      end
    end
  end
end
