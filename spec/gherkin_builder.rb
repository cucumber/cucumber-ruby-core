module GherkinBuilder
  def gherkin(&source)
    builder = Gherkin.new(&source)
    builder.build
  end

  module HasOptionsInitializer
    attr_reader :name, :options
    private :name, :options

    def initialize(*args)
      @options = args.pop if args.last.is_a?(Hash)
      @options ||= {}
      @name = args.first
    end
  end

  module HasElements
    def build(source = [])
      elements.inject(source + statements) { |acc, el| el.build(acc) }
    end

    private
    def elements
      @elements ||= []
    end
  end

  module Indentation
    def self.level(number)
      Module.new do
        define_method :indent do |string|
          (' ' * number) + string
        end
      end
    end
  end

  class Gherkin
    def initialize(&source)
      @source = source
    end

    def feature(*args, &source)
      @feature = Feature.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
      end
      self
    end

    def build
      instance_exec &@source
      @feature.build.join("\n")
    end
  end

  class Feature
    include HasElements
    include HasOptionsInitializer

    def build(source = [])
      elements.inject(source + statements) { |acc, el| el.build(acc) + [''] }
    end

    def background(*args, &source)
      Background.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    def scenario(*args, &source)
      Scenario.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    private
    def language
      options[:language]
    end

    def keyword
      options.fetch(:keyword) { 'Feature' }
    end

    def statements
      strings = [
        language_statement,
        name_statement,
        ''
      ].compact
    end

    def language_statement
      "# language: #{language}" if language
    end

    def keyword
      options.fetch(:keyword) { 'Feature' }
    end

    def name_statement
      "#{keyword}: #{name}".strip
    end
  end

  class Background
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 2

    def step(*args, &source)
      Step.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end

    private
    def statements
      [ name_statement ].map { |s| indent(s) }
    end

    def keyword
      options.fetch(:keyword) { 'Background' }
    end

    def name_statement
      "#{keyword}: #{name}".strip
    end

  end

  class Scenario
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 2

    def step(*args, &source)
      Step.new(*args).tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
      self
    end


    def build(source)
      super
    end

    private
    def statements
      [ name_statement ].map { |s| indent(s) }
    end

    def keyword
      options.fetch(:keyword) { 'Scenario' }
    end

    def name_statement
      "#{keyword}: #{name}".strip
    end

  end

  class Step
    include HasElements
    include HasOptionsInitializer
    include Indentation.level 4

    def doc_string(string)
      elements << DocString.new(string)
    end

    def table(&source)
      Table.new.tap do |builder|
        builder.instance_exec(&source) if source
        elements << builder
      end
    end

    private
    def statements
      [ name_statement ].map { |s| indent(s) }
    end

    def name_statement
      "#{keyword} #{name}"
    end

    def keyword
      options.fetch(:keyword) { 'Given' }
    end
  end

  class Table
    include Indentation.level(6)

    def row(*cells)
      rows << cells
    end

    def build(source)
      source + statements
    end

    private
    def rows
      @rows ||= []
    end

    def statements
      rows.map do |row|
        "| #{pad(row).join(' | ')} |"
      end.map { |s| indent(s) }
    end

    def pad(row)
      row.map.with_index { |cell, index| cell.ljust(column_length(index)) }
    end

    def column_length(column)
      lengths = rows.transpose.map { |r| r.map(&:length).max }
      lengths[column]
    end
  end

  class DocString
    include Indentation.level(6)

    def initialize(string)
      @strings = string.split("\n").map(&:strip)
    end

    def build(source)
      source + statements
    end

    def statements
      [
        doc_string_statement
      ].flatten.map { |s| indent(s) }
    end

    def doc_string_statement
      [
        '"""',
        @strings,
        '"""'
      ]
    end
  end
end
