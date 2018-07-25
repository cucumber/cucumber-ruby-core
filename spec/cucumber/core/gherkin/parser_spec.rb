# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require 'cucumber/core/gherkin/parser'
require 'cucumber/core/gherkin/writer'

module Cucumber
  module Core
    module Gherkin
      describe Parser do
        let(:receiver)  { double }
        let(:event_bus) { double }
        let(:parser)    { Parser.new(receiver, event_bus) }
        let(:visitor)   { double }

        before do
          allow( event_bus ).to receive(:gherkin_source_parsed)
        end

        def parse
          parser.document(source)
        end

        context "for invalid gherkin" do
          let(:source) { Gherkin::Document.new(path, "\nnot gherkin\n\nFeature: \n") }
          let(:path)   { 'path_to/the.feature' }

          it "raises an error" do
            expect { parse }.to raise_error(ParseError) do |error|
              expect( error.message ).to match(/not gherkin/)
              expect( error.message ).to match(/#{path}/)
            end
          end
        end

        context "for valid gherkin" do
          let(:source) { Gherkin::Document.new(path, 'Feature:') }
          let(:path)   { 'path_to/the.feature' }

          it "issues a gherkin_source_parsed event" do
            allow( receiver ).to receive(:pickles)
            expect( event_bus ).to receive(:gherkin_source_parsed)
            parse
          end

          it "passes on the uri" do
            expect( receiver ).to receive(:pickles).with(anything, path)
            parse
          end
        end

        context "for empty files" do
          let(:source) { Gherkin::Document.new(path, '') }
          let(:path)   { 'path_to/the.feature' }

          it "passes on an empty list of pickles" do
            expect( receiver ).to receive(:pickles).with([], anything)
            parse
          end
        end

        include Writer
        def self.source(&block)
          let(:source) { gherkin(&block) }
        end

        RSpec::Matchers.define :pickles_with_language do |language|
          match { |actual| actual.each { |pickle| pickle[:language] == language } }
        end

        context "when the Gherkin has a language header" do
          source do
            feature(language: 'ja', keyword: '機能')
          end

          it "the pickles have the correct language" do
            expect( receiver ).to receive(:pickles).with(pickles_with_language('ja'), anything)
            parse
          end
        end

        RSpec::Matchers.define :a_list_of_one_pickle do
          match { |actual| actual.length == 1 }
        end

        context "when the Gherkin produces one pickle" do
          source do
            feature do
              scenario do
                step 'text'
              end
            end
          end

          it "passes on a list with the pickle" do
            expect( receiver ).to receive(:pickles).with(a_list_of_one_pickle, anything)
            parse
          end
        end

      end
    end
  end
end
