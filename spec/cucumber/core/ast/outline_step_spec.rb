require 'cucumber/core/ast/outline_step'
require 'cucumber/core/ast/examples_table'
require 'cucumber/core/ast/data_table'
require 'cucumber/core/ast/doc_string'

module Cucumber
  module Core
    module Ast
      describe OutlineStep do
        describe "converting to a Step" do
          let(:outline_step) { OutlineStep.new(language, location, keyword, name) }
          let(:language) { double }
          let(:location) { double }
          let(:keyword)  { double }

          context "a single argument in the name" do
            let(:name) { 'a <color> cucumber' }

            it "replaces the argument" do
              row = ExamplesTable::Row.new({'color' => 'green'}, 1, location)
              outline_step.to_step(row).name.should == 'a green cucumber'
            end

          end

          context "when the step has a DataTable" do
            let(:outline_step) { OutlineStep.new(language, location, keyword, name, table) }
            let(:name)  { "anything" }
            let(:table) { DataTable.new([['x', 'y'],['a', 'a <arg>']]) }

            it "replaces the arguments in the DataTable" do
              visitor = double
              visitor.stub(:step).and_yield
              visitor.should_receive(:table) do |data_table| # TODO: rename this message to :data_table
                data_table.raw.should == [['x', 'y'], ['a', 'a replacement']]
              end
              row = ExamplesTable::Row.new({'arg' => 'replacement'}, 1, location)
              step = outline_step.to_step(row)
              step.describe_to(visitor)
            end
          end

          context "when the step has a DocString" do
            let(:outline_step) { OutlineStep.new(language, location, keyword, name, doc_string) }
            let(:doc_string) { DocString.new('a <arg> that needs replacing', '') }
            let(:name) { 'anything' }

            it "replaces the arguments in the DocString" do
              visitor = double
              visitor.stub(:step).and_yield
              visitor.should_receive(:doc_string) do |doc_string|
                doc_string.content.should == "a replacement that needs replacing"
              end
              row = ExamplesTable::Row.new({'arg' => 'replacement'}, 1, location)
              step = outline_step.to_step(row)
              step.describe_to(visitor)
            end
          end
        end
      end
    end
  end
end

