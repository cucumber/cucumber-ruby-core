require 'cucumber/core/gherkin/parser'
require 'cucumber/core/compiler'
require 'cucumber/core/test/runner'
require 'cucumber/core/test/mapper'
require 'cucumber/core/test/hook_compiler'

module Cucumber
  module Core

    def parse(gherkin_documents, compiler)
      parser = Core::Gherkin::Parser.new(compiler)
      gherkin_documents.each do |document|
        parser.document document
      end
      self
    end

    def compile(gherkin_documents, last_receiver, filters = [])
      first_receiver = filters.reduce(last_receiver) do |receiver, (filter_type, args)|
        filter_type.new(*args + [receiver])
      end
      compiler = Compiler.new(first_receiver)
      parse gherkin_documents, compiler
      self
    end

    def execute(gherkin_documents, mappings, report, filters = [], options = {})
      run_mode = options.fetch(:run_mode) { :default }

      receiver = Test::Runner.runner_from(run_mode, report)
      filters << [Test::HookCompiler, [mappings]]
      filters << [Test::Mapper, [mappings]]
      compile gherkin_documents, receiver, filters
      self
    end

  end
end
