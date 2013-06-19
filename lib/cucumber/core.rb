require 'cucumber/core/parser.rb'
require 'cucumber/core/compiler.rb'

module Cucumber
  module Core
    def parse_gherkin(source, path='unknown')
      Parser.new(source, path).feature
    end

    def compile(features)
      Compiler.new(features).test_suite
    end

    def execute(test_suite, mappings, report)
      test_suite.execute(mappings, report)
    end
  end
end
