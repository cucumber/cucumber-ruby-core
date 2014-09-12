require 'cucumber/core/ast/location'

module Cucumber::Core::Ast
  describe Location do
    let(:line) { 12 }
    let(:file) { "foo.feature" }

    describe "equality" do
      it "is equal to another Location on the same line of the same file" do
        one_location = Location.new(file, line)
        another_location = Location.new(file, line)
        expect( one_location ).to eq another_location
      end

       it "is not equal to a wild card of the same file" do
         expect( Location.new(file, line) ).not_to eq Location.new(file)
       end

      context "collections of locations" do
        it "behave as expected with uniq" do
          unique_collection = [Location.new(file, line), Location.new(file, line)].uniq
          expect( unique_collection ).to eq [Location.new(file, line)]
        end
      end
    end

    describe "line" do
      it "is an integer" do
        expect(Location.new(file, line).line).to be_kind_of(Integer)
        expect(Location.new(file, 1..2).line).to be_kind_of(Integer)
        expect(Location.of_caller.line).to be_kind_of(Integer)
      end
    end

    describe "to_s" do
      it "is file:line for a precise location" do
        expect( Location.new("foo.feature", 12).to_s ).to eq "foo.feature:12"
      end

      it "is file for a wildcard location" do
        expect( Location.new("foo.feature").to_s ).to eq "foo.feature"
      end

      it "is file:first_line..last_line for a ranged location" do
        expect( Location.new("foo.feature", 13..19).to_s ).to eq "foo.feature:13..19"
      end
    end

    describe "matches" do
      let(:matching) { Location.new(file, line) }
      let(:same_file_other_line) { Location.new(file, double) }
      let(:not_matching) { Location.new(other_file, line) }
      let(:other_file) { double }

      context 'a precise location' do
        let(:precise) { Location.new(file, line) }

        it "matches a precise location of the same file and line" do
          expect( matching ).to be_match(precise)
        end

        it "does not match a precise location on a differnt line in the same file" do
          expect( matching ).not_to be_match(same_file_other_line)
        end

      end

      context 'a wildcard' do
        let(:wildcard) { Location.new(file) }

        it "matches any location with the same filename" do
          expect( wildcard ).to be_match(matching)
        end

        it "is matched by any location of the same file" do
          expect( matching ).to be_match(wildcard)
        end

        it "does not match a location in a different file" do
          expect( wildcard ).not_to be_match(not_matching)
        end
      end

      context 'a range wildcard' do
        let(:range) { Location.new("foo.feature", 13..17) }

        it "matches the first line in the same file" do
          other = Location.new("foo.feature", 13)
          expect( range ).to be_match(other)
        end

        it "matches a line within the docstring in the same file" do
          other = Location.new("foo.feature", 15)
          expect( range ).to be_match(other)
        end

        it "is matched by a line within the docstring in the same file" do
          other = Location.new("foo.feature", 15)
          expect( other ).to be_match(range)
        end

        it "matches a wildcard in the same file" do
          wildcard = Location.new("foo.feature")
          expect( range ).to be_match(wildcard)
        end

        it "does not match a location outside of the range" do
          other = Location.new("foo.feature", 18)
          expect( range ).not_to be_match(other)
        end

        it "does not match a location in another file" do
          other = Location.new("bar.feature", 13)
          expect( range ).not_to be_match(other)
        end
      end
    end
  end
end

