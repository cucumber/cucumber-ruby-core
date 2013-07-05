require 'cucumber/core/gherkin/parser.rb'
require 'cucumber/core/compiler.rb'

module Cucumber
  module Core

    def compile(*gherkin_documents)
      compiler = Compiler.new
      parser = Core::Gherkin::Parser.new(compiler)
      gherkin_documents.map do |document|
        parser.document(document, 'UNKNOWN')
      end
      compiler.test_suite
    end

    def execute(test_suite, mappings, report)
      test_suite.execute(mappings, report)
    end

  end
end
