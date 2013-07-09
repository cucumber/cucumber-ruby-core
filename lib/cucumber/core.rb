require 'cucumber/core/gherkin/parser'
require 'cucumber/core/compiler'
require 'cucumber/core/test/runner'

module Cucumber
  module Core

    def parse(gherkin_documents, compiler)
      parser = Core::Gherkin::Parser.new(compiler)
      gherkin_documents.map do |document|
        parser.document(document, 'UNKNOWN')
      end
      self
    end

    def compile(gherkin_documents, receiver)
      compiler = Compiler.new(receiver)
      parse(gherkin_documents, compiler)
      self
    end

    def execute(gherkin_documents, mappings, report)
      runner = Test::Runner.new(mappings, report)
      compile(gherkin_documents, runner)
      self
    end

  end
end
