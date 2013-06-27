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

        describe '#map_column!' do
          it "should allow mapping columns" do
            @table.map_column!('one') { |v| v.to_i }
            @table.hashes.first['one'].should == 4444
          end

          it "applies the block once to each value" do
            headers = ['header']
            rows = ['value']
            table = DataTable.new [headers, rows]
            count = 0
            table.map_column!('header') { |value| count +=1 }
            table.rows
            count.should eq rows.size
          end

          it "should allow mapping columns and take a symbol as the column name" do
            @table.map_column!(:one) { |v| v.to_i }
            @table.hashes.first['one'].should == 4444
          end

          it "should allow mapping columns and modify the rows as well" do
            @table.map_column!(:one) { |v| v.to_i }
            @table.rows.first.should include(4444)
            @table.rows.first.should_not include('4444')
          end

          it "should pass silently if a mapped column does not exist in non-strict mode" do
            lambda {
              @table.map_column!('two', false) { |v| v.to_i }
              @table.hashes
            }.should_not raise_error
          end

          it "should fail if a mapped column does not exist in strict mode" do
            lambda {
              @table.map_column!('two', true) { |v| v.to_i }
              @table.hashes
            }.should raise_error('The column named "two" does not exist')
          end

          it "should return the table" do
            (@table.map_column!(:one) { |v| v.to_i }).should == @table
          end
        end

        describe "#match" do
          before(:each) do
            @table = DataTable.new([
              %w{one four seven},
              %w{4444 55555 666666}
            ])
          end

          it "returns nil if headers do not match" do
            @table.match('does,not,match').should be_nil
          end
          it "requires a table: prefix on match" do
            @table.match('table:one,four,seven').should_not be_nil
          end
          it "does not match if no table: prefix on match" do
            @table.match('one,four,seven').should be_nil
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

          it "should support header and column mapping" do
            table = DataTable.new([
              %w{one 1111},
              %w{two 22222}
            ])
            table.map_headers!({ 'two' => 'Two' }) { |header| header.upcase }
            table.map_column!('two', false) { |val| val.to_i }
            table.rows_hash.should == { 'ONE' => '1111', 'Two' => 22222 }
          end
        end

        describe '#map_headers' do
          it "renames the columns to the specified values in the provided hash" do
            table2 = @table.map_headers('one' => :three)
            table2.hashes.first[:three].should == '4444'
          end

          it "allows renaming columns using regexp" do
            table2 = @table.map_headers(/one|uno/ => :three)
            table2.hashes.first[:three].should == '4444'
          end

          it "copies column mappings" do
            @table.map_column!('one') { |v| v.to_i }
            table2 = @table.map_headers('one' => 'three')
            table2.hashes.first['three'].should == 4444
          end

          it "takes a block and operates on all the headers with it" do
            table = DataTable.new([
              ['HELLO', 'WORLD'],
              %w{4444 55555}
            ])

            table.map_headers! do |header|
              header.downcase
            end

            table.hashes.first.keys.should =~ %w[hello world]
          end

          it "treats the mappings in the provided hash as overrides when used with a block" do
            table = DataTable.new([
              ['HELLO', 'WORLD'],
              %w{4444 55555}
            ])

            table.map_headers!('WORLD' => 'foo') do |header|
              header.downcase
            end

            table.hashes.first.keys.should =~ %w[hello foo]
          end

          it "should allow mapping of headers before table.hashes has been accessed" do
            table = DataTable.new([
              ['HELLO', 'WORLD'],
              %w{4444 55555}
            ])

            table.map_headers! do |header|
              header.downcase
            end

            table.hashes.first.keys.should =~ %w[hello world]
          end

          it "should allow mapping of headers after table.hashes has been accessed" do
            table = DataTable.new([
              ['HELLO', 'WORLD'],
              %w{4444 55555}
            ])

            table.map_headers! do |header|
              header.downcase
            end

            table.hashes.first.keys.should =~ %w[hello world]
          end
        end

        describe "replacing arguments" do

          before(:each) do
            @table = DataTable.new([
              %w{qty book},
              %w{<qty> <book>}
            ])
          end

          it "should return a new table with arguments replaced with values" do
            table_with_replaced_args = @table.arguments_replaced({'<book>' => 'Unbearable lightness of being', '<qty>' => '5'})

            table_with_replaced_args.hashes[0]['book'].should eq('Unbearable lightness of being')
            table_with_replaced_args.hashes[0]['qty'].should eq('5')
          end

          it "should recognise when entire cell is delimited" do
            @table.should have_text('<book>')
          end

          it "should recognise when just a subset of a cell is delimited" do
            table = DataTable.new([
              %w{qty book},
              [nil, "This is <who>'s book"]
            ])
            table.should have_text('<who>')
          end

          it "should replace nil values with nil" do
            table_with_replaced_args = @table.arguments_replaced({'<book>' => nil})

            table_with_replaced_args.hashes[0]['book'].should == nil
          end

          it "should preserve values which don't match a placeholder when replacing with nil" do
            table = DataTable.new([
              %w{book},
              %w{cat}
            ])
            table_with_replaced_args = table.arguments_replaced({'<book>' => nil})

            table_with_replaced_args.hashes[0]['book'].should == 'cat'
          end

          it "should not change the original table" do
            @table.arguments_replaced({'<book>' => 'Unbearable lightness of being'})

            @table.hashes[0]['book'].should_not == 'Unbearable lightness of being'
          end

          it "should not raise an error when there are nil values in the table" do
            table = DataTable.new([
              ['book', 'qty'],
              ['<book>', nil],
            ])
            lambda{
              table.arguments_replaced({'<book>' => nil, '<qty>' => '5'})
            }.should_not raise_error
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
