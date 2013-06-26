require 'cucumber/core/ast/outline_step'
require 'cucumber/core/ast/examples_table'
require 'cucumber/core/ast/table'
require 'cucumber/core/ast/doc_string'

module Cucumber
  module Core
    module Ast
      describe OutlineStep do
        describe "converting to a Step" do
          let(:outline_step) { OutlineStep.new(language, location, keyword, name) }
          let(:language) { stub }
          let(:location) { stub }
          let(:keyword)  { stub }

          context "a single argument in the name" do
            let(:name) { 'a <color> cucumber' }

            it "replaces the argument" do
              row = ExamplesTable::Row.new('color' => 'green')
              outline_step.to_step(row).name.should == 'a green cucumber'
            end

          end

          context "when the step has a DataTable" do
            let(:outline_step) { OutlineStep.new(language, location, keyword, name, table) }
            let(:name)  { "anything" }
            let(:table) { Table.new([['x', 'y'],['a', 'a <arg>']]) } # TODO: rename to DataTable

            it "replaces the arguments in the DataTable" do
              visitor = stub
              visitor.stub(:step).and_yield
              visitor.should_receive(:table) do |data_table| # TODO: rename this message to :data_table
                data_table.raw.should == [['x', 'y'], ['a', 'a replacement']]
              end
              row = ExamplesTable::Row.new('arg' => 'replacement')
              step = outline_step.to_step(row)
              step.describe_to(visitor)
            end
          end

          context "when the step has a DocString" do
            let(:outline_step) { OutlineStep.new(language, location, keyword, name, doc_string) }
            let(:doc_string) { DocString.new('a <arg> that needs replacing', '') }
            let(:name) { 'anything' }

            it "replaces the arguments in the DocString" do
              visitor = stub
              visitor.stub(:step).and_yield
              visitor.should_receive(:doc_string) do |doc_string|
                doc_string.content.should == "a replacement that needs replacing"
              end
              row = ExamplesTable::Row.new('arg' => 'replacement')
              step = outline_step.to_step(row)
              step.describe_to(visitor)
            end
          end
        end
      end
    end
  end
end

