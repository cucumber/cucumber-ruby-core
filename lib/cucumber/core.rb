require 'cucumber/core/gherkin/parser'
require 'cucumber/core/compiler'
require 'cucumber/core/test/suite_builder'

module Cucumber
  module Core

    def compile(gherkin_documents, receiver = Test::SuiteBuilder.new)
      compiler = Compiler.new(receiver)
      parser = Core::Gherkin::Parser.new(compiler)
      gherkin_documents.map do |document|
        parser.document(document, 'UNKNOWN')
      end
      receiver.result
    end

    def execute(gherkin_documents, mappings, report)
      suite_builder = Test::SuiteBuilder.new
      compile(gherkin_documents, suite_builder)
      suite_builder.result.execute(mappings, report)
    end
  end
end
