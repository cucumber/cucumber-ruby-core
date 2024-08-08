# frozen_string_literal: true

require 'cucumber/core/test/doc_string'

describe Cucumber::Core::Test::DocString do
  let(:doc_string) { described_class.new(content, content_type) }

  describe '#data_table?' do
    let(:doc_string) { described_class.new('test', 'text/plain') }

    it 'returns false' do
      expect(doc_string).not_to be_data_table
    end
  end

  describe '#doc_string' do
    let(:doc_string) { described_class.new('test', 'text/plain') }

    it 'returns true' do
      expect(doc_string).to be_doc_string
    end
  end

  describe '#map' do
    let(:content) { 'original content' }
    let(:content_type) { double }

    it 'yields with the content' do
      expect { |b| doc_string.map(&b) }.to yield_with_args(content)
    end

    it 'returns a new docstring with new content' do
      expect(doc_string.map { 'foo' }.content).to eq('foo')
    end

    it 'raises an error if no block is given' do
      expect { doc_string.map }.to raise_error ArgumentError
    end
  end

  describe 'DocString equality properties' do
    let(:content) { 'foo' }
    let(:content_type) { 'text/plain' }

    it 'is equal to another DocString with the same content and content_type' do
      expect(doc_string).to eq(described_class.new(content, content_type))
    end

    it 'is not equal to another DocString with different content' do
      expect(doc_string).not_to eq(described_class.new('bar', content_type))
    end

    it 'is not equal to another DocString with different content_type' do
      expect(doc_string).not_to eq(described_class.new(content, 'text/html'))
    end

    it 'is equal to a string with the same content' do
      expect(doc_string).to eq('foo')
    end

    it 'returns false when compared with something odd' do
      expect(doc_string).not_to eq(5)
    end
  end

  describe 'DocString has String-like properties' do
    let(:content) { String.new('content') }
    let(:content_type) { 'text/plain' }

    it 'delegates #encoding to the content string' do
      content.force_encoding('us-ascii')

      expect(doc_string.encoding).to eq(Encoding.find('US-ASCII'))
    end

    it 'allows implicit conversion to a String' do
      expect("I have a string of #{doc_string}").to eq('I have a string of content')
    end

    it 'allows explicit conversion to a String' do
      expect(doc_string.to_s).to eq('content')
    end

    it 'delegates #gsub to the content string' do
      expect(doc_string.gsub('n', '_')).to eq('co_te_t')
    end

    it 'delegates #split to the content string' do
      expect(doc_string.split('n')).to eq(%w[co te t])
    end
  end

  describe '#inspect' do
    let(:content_type) { 'text/plain' }
    let(:doc_string) { described_class.new('some text', content_type) }

    it 'provides a useful inspect method' do
      expect(doc_string.inspect).to eq(<<~DOC_STRING.chomp)
        #<Cucumber::Core::Test::DocString
          """text/plain
          some text
          """>
      DOC_STRING
    end
  end
end
