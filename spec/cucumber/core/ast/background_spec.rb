require 'cucumber/core/ast/background'

module Cucumber::Core::Ast
  describe Background do
    let(:background) { Background.new(language, location, comment, keyword, title, description, steps) }
    let(:language) { stub }
    let(:location) { stub }
    let(:comment) { stub }
    let(:keyword) { stub }
    let(:title) { stub }
    let(:description) { stub }
    let(:steps) { stub }

    it "has a location" do
      background.should respond_to(:location)
    end
  end
end
