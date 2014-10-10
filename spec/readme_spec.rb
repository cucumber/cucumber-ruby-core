require 'stringio'
require 'redcarpet'

describe "README.md code snippet" do
  let(:code_blocks) do
    markdown = File.read(File.expand_path(File.dirname(__FILE__) + '/../README.md'))
    parse_ruby_from(markdown)
  end

  it "executes with the expected output" do
    code, output = *code_blocks
    expect(execute_ruby(code)).to eq output
  end

  def execute_ruby(code)
    capture_stdout do
      eval code, binding
    end
  end

  def parse_ruby_from(markdown)
    readme = Readme.parse(markdown)
    expect(readme.code_blocks).not_to be_empty
    readme.code_blocks
  end

  def capture_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
    result = $stdout.string
    $stdout = original
    result
  end

  class Readme < Redcarpet::Render::Base
    def self.parse(markdown)
      result = new
      Redcarpet::Markdown.new(result, fenced_code_blocks: true).render(markdown)
      result
    end

    def block_code(code, language)
      code_blocks << code
      nil
    end

    def code_blocks
      @code_blocks ||= []
    end
  end

end
