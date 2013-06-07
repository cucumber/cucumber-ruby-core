require 'cucumber/initialize'

module Cucumber
  describe 'generating initializers' do
    class Book
      include Cucumber::Initialize(:title, :author)

      def description
        "#{title} by #{author}"
      end

      def upcase!
        @title.upcase!
        @author.upcase!
      end
    end

    let(:cucumber_book) { Book.new('The Cucumber Book', 'Matt Wynne') }

    it 'raises an ArgumentError when initialized with the wrong number of arguments' do
      expect { Book.new() }.to raise_error(ArgumentError, 'wrong number of arguments (0 for 2)')
    end

    it 'creates a private reader for the attributes' do
      expect { cucumber_book.title }.to raise_error(NoMethodError)
      expect { cucumber_book.author }.to raise_error(NoMethodError)
    end

    it 'creates readers for the attributes' do
      cucumber_book.description.should == 'The Cucumber Book by Matt Wynne'
    end

    it 'creates instance variables for the attributes' do
      cucumber_book.upcase!
      cucumber_book.description.should == 'THE CUCUMBER BOOK by MATT WYNNE'
    end

    context 'with an overridden reader' do
      class Score
        include Cucumber::Initialize(:score)
        attr_reader :score
      end

      it 'makes the reader public' do
        expect { Score.new(12).score }.to_not raise_error
      end
    end
  end
end
