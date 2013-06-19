# -*- encoding: utf-8 -*-
require 'cucumber/initializer'
require 'cucumber/core/parser'
require 'gherkin_builder'

module Cucumber
  module Core
    module Ast
      describe Parser do
        include ::GherkinBuilder

        let(:feature) do
          Parser.new(source, __FILE__).feature
        end

        def self.source(&block)
          let(:source) do
            gherkin(&block)
          end
        end

        context "when the Gherkin has a language header" do
          source do
            feature(language: 'ja', keyword: '機能')
          end

          it "sets the language from the Gherkin" do
            feature.language.iso_code.should == 'ja'
          end
        end

        context "a Scenario with a DocString" do
          source do
            feature do
              scenario do
                step do
                  doc_string("content")
                end
              end
            end
          end

          it "parses doc strings without error" do
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

