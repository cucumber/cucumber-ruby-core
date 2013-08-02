require 'cucumber/core/gherkin/parser'
require 'cucumber/core/compiler'
require 'cucumber/core/test/runner'
require 'cucumber/core/test/mapper'
require 'cucumber/core/test/hook_compiler'
require 'cucumber/core/test/tag_filter'

module Cucumber
  module Core

    def parse(gherkin_documents, compiler)
      parser = Core::Gherkin::Parser.new(compiler)
      gherkin_documents.each do |document|
        parser.document document
      end
      self
    end

    def compile(gherkin_documents, receiver, options = {})
      if options.key?(:filter)
        receiver = Test::TagFilter.new(options[:filter], receiver)
      end
      compiler = Compiler.new(receiver)
      parse gherkin_documents, compiler
      self
    end

    def execute(gherkin_documents, mappings, report, options = {})
      runner = Test::Runner.new(report)
      hook_compiler = Test::HookCompiler.new(mappings, runner)
      mapper = Test::Mapper.new(mappings, hook_compiler)
      compile gherkin_documents, mapper, options
      self
    end

  end
end
