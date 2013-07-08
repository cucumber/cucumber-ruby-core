require 'cucumber/core/ast/doc_string'

module Cucumber
  module Core
    module Ast
      describe DocString do
        context '#map' do
          let(:doc_string) { DocString.new(original_content, content_type) }
          let(:original_content) { 'original content' }
          let(:content_type) { double }

          it 'yields with the content' do
            expect { |b| doc_string.map(&b) }.to yield_with_args(original_content)
          end

          it 'returns a new docstring with new content' do
            doc_string.map { 'foo' }.content.should == 'foo'
          end

          it 'raises an error if no block is given' do
            expect { doc_string.map }.to raise_error ArgumentError
          end
        end

        context 'equality' do
          let(:doc_string) { DocString.new('foo', 'bar') }

          it 'is equal to another DocString with the same content and content_type' do
            doc_string.should == DocString.new('foo', 'bar')
          end

          it 'is not equal to another DocString with different content' do
            doc_string.should_not == DocString.new('baz', 'bar')
          end

          it 'is not equal to another DocString with different content_type' do
            doc_string.should_not == DocString.new('foo', 'baz')
          end
        end
      end
    end
  end
end
