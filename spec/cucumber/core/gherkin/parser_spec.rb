# -*- encoding: utf-8 -*-
require 'cucumber/initializer'
require 'cucumber/core/gherkin/parser'
require 'cucumber/core/gherkin/writer'

module Cucumber
  module Core
    module Gherkin
      describe Parser do
        let(:receiver) { double }
        let(:parser)   { Parser.new(receiver) }
        let(:visitor)  { double }

        def parse
          parser.document(source)
        end

        context "for invalid gherkin" do
          let(:source) { Gherkin::Document.new(path, 'not gherkin') }
          let(:path)   { 'path_to/the.feature' }

          it "raises an error" do
            expect { parse }.to raise_error(ParseError) do |error|
              error.message.should =~ /not gherkin/
              error.message.should =~ /#{path}/
            end
          end
        end

        include Writer
        def self.source(&block)
          let(:source) { gherkin(&block) }
        end

        def feature
          result = nil
          receiver.stub(:feature) { |feature| result = feature }
          parse
          result
        end

        context "when the Gherkin has a language header" do
          source do
            feature(language: 'ja', keyword: '機能')
          end

          it "sets the language from the Gherkin" do
            feature.language.iso_code.should == 'ja'
          end
        end

        context "a Scenario with a DocString" do
          source do
            feature do
              scenario do
                step do
                  doc_string("content")
                end
              end
            end
          end

          it "parses doc strings without error" do
            visitor.stub(:feature).and_yield
            visitor.stub(:scenario).and_yield
            visitor.stub(:step).and_yield

            expected = Ast::DocString.new("content", "")
            visitor.should_receive(:doc_string).with(expected)
            feature.describe_to(visitor)
          end

        end

        context "a Scenario with a DataTable" do
          source do
            feature do
              scenario do
                step do
                  table do
                    row "name", "surname"
                    row "rob",  "westgeest"
                  end
                end
              end
            end
          end

          it "parses the DataTable" do
            visitor = double
            visitor.stub(:feature).and_yield
            visitor.stub(:scenario).and_yield
            visitor.stub(:step).and_yield

            expected = Ast::DataTable.new([['name', 'surname'], ['rob', 'westgeest']])
            visitor.should_receive(:table).with(expected)
            feature.describe_to(visitor)
          end
        end

        context "a Scenario with a Comment" do
          source do
            feature do
              scenario(comment: 'wow')
            end
          end

          it "parses the comment into the AST" do
            visitor = double
            visitor.stub(:feature).and_yield
            visitor.should_receive(:scenario) do |scenario|
              scenario.comment.to_s.should == "# wow"
            end
            feature.describe_to(visitor)
          end
        end

        context "a Scenario Outline" do
          source do
            feature do
              scenario_outline 'outline name' do
                step 'passing <arg>'

                examples do
                  row 'arg'
                  row '1'
                  row '2'
                end

                examples do
                  row 'arg'
                  row 'a'
                end
              end
            end
          end

          it "creates a scenario outline node" do
            visitor.stub(:feature).and_yield
            visitor.should_receive(:scenario_outline) do |outline|
              outline.name.should == 'outline name'
            end
            feature.describe_to(visitor)
          end

          it "creates a step node for each step of the scenario outline" do
            visitor.stub(:feature).and_yield
            visitor.stub(:scenario_outline).and_yield
            visitor.stub(:examples_table)
            visitor.should_receive(:outline_step) do |step|
              step.name.should == 'passing <arg>'
            end
            feature.describe_to(visitor)
          end

          it "creates an examples table node for each examples table" do
            visitor.stub(:feature).and_yield
            visitor.stub(:scenario_outline).and_yield
            visitor.stub(:outline_step)
            visitor.should_receive(:examples_table).exactly(2).times.and_yield
            visitor.should_receive(:examples_table_row) do |row|
              row.number.should eq(1)
              row.values.should == ['1']
            end.once.ordered
            visitor.should_receive(:examples_table_row) do |row|
              row.number.should eq(2)
              row.values.should == ['2']
            end.once.ordered
            visitor.should_receive(:examples_table_row) do |row|
              row.number.should eq(1)
              row.values.should == ['a']
            end.once.ordered
            feature.describe_to(visitor)
          end

        end
      end
    end
  end
end
