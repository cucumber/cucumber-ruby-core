require 'cucumber/core/gherkin/parser.rb'
require 'cucumber/core/compiler.rb'

module Cucumber
  module Core
    def parse_gherkin(source, path='unknown')
      Gherkin::Parser.new(source, path).feature
    end

    def compile(ast)
      Compiler.new(ast).test_suite
    end

    def execute(test_suite, mappings, report)
      test_suite.execute(mappings, report)
    end
  end
end
