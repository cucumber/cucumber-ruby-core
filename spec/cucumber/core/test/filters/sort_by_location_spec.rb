require 'cucumber/core/gherkin/writer'
require 'cucumber/core'
require 'cucumber/core/test/filters/sort_by_location'

module Cucumber::Core::Test
  describe SortByLocation do
    include Cucumber::Core::Gherkin::Writer
    include Cucumber::Core

    describe ".new" do
      let(:receiver) { double.as_null_object }

      let(:doc) { 
        gherkin do
          feature do
            scenario 'x' do
              step 'a step'
            end

            scenario 'y' do
              step 'a step'
            end
          end
        end
      }

      it "sorts by the given locations" do
        locations = [
          Cucumber::Core::Ast::Location.new('features/test.feature', 6),
          Cucumber::Core::Ast::Location.new('features/test.feature', 3)
        ]
        filter = SortByLocation.new(locations)
        expect(receiver).to receive(:test_case) { |test_case|
          expect(test_case.name).to match(/y/)
        }.once.ordered
        expect(receiver).to receive(:test_case) { |test_case|
          expect(test_case.name).to match(/x/)
        }.once.ordered
        compile [doc], receiver, [filter]
      end

      it "works with wildcard locations" do
        locations = [
          Cucumber::Core::Ast::Location.new('features/test.feature')
        ]
        filter = SortByLocation.new(locations)
        expect(receiver).to receive(:test_case) { |test_case|
          expect(test_case.name).to match(/x/)
        }.once.ordered
        expect(receiver).to receive(:test_case) { |test_case|
          expect(test_case.name).to match(/y/)
        }.once.ordered
        compile [doc], receiver, [filter]
      end

      it "filters out scenarios that don't match" do
        locations = [
          Cucumber::Core::Ast::Location.new('features/test.feature', 3)
        ]
        filter = SortByLocation.new(locations)
        expect(receiver).to receive(:test_case) { |test_case|
          expect(test_case.name).to match(/x/)
        }.once.ordered
        compile [doc], receiver, [filter]
      end

      def run(filter)
        compile [doc], receiver, [filter]
      end
    end
  end
end
