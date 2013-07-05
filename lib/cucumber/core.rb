require 'cucumber/core/gherkin/parser.rb'
require 'cucumber/core/compiler.rb'

module Cucumber
  module Core

    def compile(*gherkin_documents)
      ast = gherkin_documents.map do |document|
        Gherkin::Parser.new(document, 'UNKNOWN').feature
      end
      Compiler.new(ast).test_suite
    end

    def execute(test_suite, mappings, report)
      test_suite.execute(mappings, report)
    end

  end
end
