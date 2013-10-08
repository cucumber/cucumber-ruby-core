require 'cucumber/core/ast/location'

module Cucumber::Core::Ast
  describe Location do
    let(:line) { double }
    let(:file) { double }

    describe "equality" do
      it "is equal to another Location on the same line of the same file" do
        one_location = Location.new(file, line)
        another_location = Location.new(file, line)
        one_location.should == another_location
      end

       it "is not equal to a wild card of the same file" do
         Location.new(file, line).should_not == Location.new(file)
       end
    end

    describe "to_s" do
      it "is file:line for a precise location" do
        Location.new("foo.feature", "12").to_s.should == "foo.feature:12"
      end

      it "is file for a wildcard location" do
        Location.new("foo.feature").to_s.should == "foo.feature"
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
          matching.should be_match(precise)
        end

        it "does not match a precise location on a differnt line in the same file" do
          matching.should_not be_match(same_file_other_line)
        end

      end

      context 'a wildcard' do
        let(:wildcard) { Location.new(file) }

        it "matches any location with the same filename" do
          wildcard.should be_match(matching)
        end

        it "is matched by any location of the same file" do
          matching.should be_match(wildcard)
        end

        it "does not match a location in a different file" do
          wildcard.should_not be_match(not_matching)
        end
      end
    end
  end
end

