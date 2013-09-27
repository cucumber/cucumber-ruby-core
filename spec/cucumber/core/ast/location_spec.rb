require 'cucumber/core/ast/location'

module Cucumber::Core::Ast
  describe Location do
    describe "equality" do
      it "is equal to another Location on the same line of the same file" do
        file, line = double, double
        one_location = Location.new(file, line)
        another_location = Location.new(file, line)
        one_location.should == another_location
      end
    end
  end
end

