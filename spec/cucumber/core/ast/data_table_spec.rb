# encoding: utf-8
require 'cucumber/core/ast/data_table'

module Cucumber
  module Core
    module Ast
      describe DataTable do
        before do
          @table = DataTable.new([
            %w{one four seven},
            %w{4444 55555 666666}
          ])
          def @table.cells_rows; super; end
          def @table.columns; super; end
        end

        it "should have rows" do
          @table.cells_rows[0].map{|cell| cell.value}.should == %w{one four seven}
        end

        it "should have columns" do
          @table.columns[1].map{|cell| cell.value}.should == %w{four 55555}
        end

        it "should have headers" do
          @table.headers.should == %w{one four seven}
        end

        it "should have same cell objects in rows and columns" do
          # 666666
          @table.cells_rows[1].__send__(:[], 2).should equal(@table.columns[2].__send__(:[], 1))
        end

        it "should know about max width of a row" do
          @table.columns[1].__send__(:width).should == 5
        end

        it "should be convertible to an array of hashes" do
          @table.hashes.should == [
            {'one' => '4444', 'four' => '55555', 'seven' => '666666'}
          ]
        end

        it "should accept symbols as keys for the hashes" do
          @table.hashes.first[:one].should == '4444'
        end

        it "should return the row values in order" do
          @table.rows.first.should == %w{4444 55555 666666}
        end

        describe "equality" do
          it "is equal to another table with the same data" do
            DataTable.new([[1,2],[3,4]]).should == DataTable.new([[1,2],[3,4]])
          end

          it "is not equal to another table with different data" do
            DataTable.new([[1,2],[3,4]]).should_not == DataTable.new([[1,2]])
          end

          it "is not equal to a non table" do
            DataTable.new([[1,2],[3,4]]).should_not == Object.new
          end
        end

        describe "#map" do
          let(:table) { DataTable.new([ %w{foo bar}, %w{1 2} ]) }

          it 'yields the contents of each cell to the block' do

            expect { |b| table.map(&b) }.to yield_successive_args('foo', 'bar', '1', '2')
          end

          it 'returns a new table with the cells modified by the block' do
            table.map { |cell| "*#{cell}*" }.should ==  DataTable.new([%w{*foo* *bar*}, %w{*1* *2*}])
          end
        end

        describe "#transpose" do
          before(:each) do
            @table = DataTable.new([
              %w{one 1111},
              %w{two 22222}
            ])
          end

          it "should be convertible in to an array where each row is a hash" do
            @table.transpose.hashes[0].should == {'one' => '1111', 'two' => '22222'}
          end
        end

        describe "#rows_hash" do

          it "should return a hash of the rows" do
            table = DataTable.new([
              %w{one 1111},
              %w{two 22222}
            ])
            table.rows_hash.should == {'one' => '1111', 'two' => '22222'}
          end

          it "should fail if the table doesn't have two columns" do
            faulty_table = DataTable.new([
              %w{one 1111 abc},
              %w{two 22222 def}
            ])
            lambda {
              faulty_table.rows_hash
            }.should raise_error('The table must have exactly 2 columns')
          end
        end

        describe "#new" do
          it "should allow Array of Hash" do
            t1 = DataTable.new([{'name' => 'aslak', 'male' => 'true'}])
            t1.hashes.should == [{'name' => 'aslak', 'male' => 'true'}]
          end
        end

        it "should convert to sexp" do
          @table.to_sexp.should ==
            [:table,
             [:row, -1,
              [:cell, "one"],
              [:cell, "four"],
              [:cell, "seven"]
          ],
          [:row, -1,
           [:cell, "4444"],
           [:cell, "55555"],
           [:cell, "666666"]]]
        end
      end
    end
  end
end
