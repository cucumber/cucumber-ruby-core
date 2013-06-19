require 'cucumber/initializer'
require 'cucumber/core/parser'
require 'gherkin_builder'

module Cucumber
  module Core
    module Ast
      describe Parser do
        include ::GherkinBuilder

        def parse_gherkin(source)
          Parser.new(source, __FILE__).feature
        end

        context "a Scenario with a DocString" do
          it "parses doc strings without error" do
            feature = parse_gherkin(
              gherkin do
                feature do
                  scenario do
                    step do
                      doc_string("content")
                    end
                  end
                end
              end
            )
            visitor = stub
            visitor.stub(:feature).and_yield
            visitor.stub(:scenario).and_yield
            visitor.stub(:step).and_yield

            expected = Core::Ast::DocString.new("content", "")
            visitor.should_receive(:doc_string).with(expected)
            feature.describe_to(visitor)
          end

        end
      end
    end
  end
end

