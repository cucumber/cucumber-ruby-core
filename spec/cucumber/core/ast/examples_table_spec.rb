require 'cucumber/core/ast/examples_table'

module Cucumber::Core::Ast
  describe ExamplesTable do
    let(:location) { double }

    describe ExamplesTable::Header do
      context 'building a row' do
        it 'includes the header values as keys' do
          header = ExamplesTable::Header.new(%w{foo bar baz})
          header.build_row(%w{1 2 3}, 1, location).should ==
            ExamplesTable::Row.new({'foo' => '1', 'bar' => '2', 'baz' => '3'}, 1, location)
        end
      end
    end
    describe ExamplesTable::Row do

      describe "expanding a string" do
        context "when an argument matches" do
          it "replaces the argument with the value from the row" do
            row = ExamplesTable::Row.new({'arg' => 'replacement'}, 1, location)
            text = 'this <arg> a test'
            row.expand(text).should == 'this replacement a test'
          end
        end

        context "when the replacement value is nil" do
          it "uses an empty string for the replacement" do
            row = ExamplesTable::Row.new({'color' => nil}, 1, location)
            text = 'a <color> cucumber'
            row.expand(text).should == 'a  cucumber'
          end
        end

        context "when an argument does not match" do
          it "ignores the arguments that do not match" do
            row = ExamplesTable::Row.new({'x' => '1', 'y' => '2'}, 1, location)
            text = 'foo <x> bar <z>'
            row.expand(text).should == 'foo 1 bar <z>'
          end
        end
      end

      describe 'accesing the values' do
        it 'returns the actual row values' do
          row = ExamplesTable::Row.new({'x' => '1', 'y' => '2'}, 1, location)
          row.values.should == ['1', '2']
        end
      end
    end
  end
end
