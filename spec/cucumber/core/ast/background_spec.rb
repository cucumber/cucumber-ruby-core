require 'cucumber/core/ast/background'

module Cucumber::Core::Ast
  describe Background do
    let(:background) { Background.new(language, location, comment, keyword, title, description, steps) }
    let(:language) { double }
    let(:location) { double }
    let(:comment) { double }
    let(:keyword) { double }
    let(:title) { double }
    let(:description) { double }
    let(:steps) { double }

    it "has a location" do
      expect( background ).to respond_to(:location)
    end
  end
end
