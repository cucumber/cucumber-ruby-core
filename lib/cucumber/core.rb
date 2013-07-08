require 'cucumber/core/gherkin/parser'
require 'cucumber/core/compiler'

module Cucumber
  module Core
    def compile(gherkin_documents, receiver)
      compiler = Compiler.new(receiver)
      parser = Core::Gherkin::Parser.new(compiler)
      gherkin_documents.map do |document|
        parser.document(document, 'UNKNOWN')
      end
      self
    end

    def execute(gherkin_documents, mappings, report)
      runner = Test::SuiteRunner.new(mappings, report)
      compile(gherkin_documents, runner)
      self
    end
  end
end
