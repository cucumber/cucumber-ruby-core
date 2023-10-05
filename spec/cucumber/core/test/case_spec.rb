# frozen_string_literal: true

require 'cucumber/core'
require 'cucumber/core/gherkin/writer'
require 'cucumber/core/platform'
require 'cucumber/core/test/case'

describe Cucumber::Core::Test::Case do
  include Cucumber::Core
  include Cucumber::Core::Gherkin::Writer

  let(:name) { double }
  let(:test_steps) { [double, double] }
  let(:location) { double }
  let(:tags) { double }
  let(:language) { double }
  let(:test_case) do
    described_class.new(
      id: double,
      name: name,
      test_steps: test_steps,
      location: location,
      parent_locations: double,
      tags: tags,
      language: language
    )
  end

  describe '#describe_to' do
    let(:visitor) { double }
    let(:args) { double }

    it 'describes itself to a visitor' do
      expect(visitor).to receive(:test_case).with(test_case, args)

      test_case.describe_to(visitor, args)
    end

    it 'asks each test_step to describe themselves to the visitor' do
      expect(test_steps).to all receive(:describe_to).with(visitor, args)

      allow(visitor).to receive(:test_case).and_yield(visitor)
      test_case.describe_to(visitor, args)
    end

    it 'describes around hooks in order' do
      allow(visitor).to receive(:test_case).and_yield(visitor)
      first_hook = double
      second_hook = double
      expect(first_hook).to receive(:describe_to).ordered.and_yield
      expect(second_hook).to receive(:describe_to).ordered.and_yield
      around_hooks = [first_hook, second_hook]
      test_case.with(test_steps: [], around_hooks: around_hooks).describe_to(visitor, double)
    end
  end

  describe '#name' do
    it 'the name is passed when creating the test case' do
      expect(test_case.name).to eq(name)
    end
  end

  describe '#location' do
    it 'the location is passed when creating the test case' do
      expect(test_case.location).to eq(location)
    end
  end

  describe '#tags' do
    it 'the tags are passed when creating the test case' do
      expect(test_case.tags).to eq(tags)
    end
  end

  describe '#match_tags?' do
    let(:tags) { %w[@a @b @c].map { |value| Cucumber::Core::Test::Tag.new(location, value) } }

    it 'matches tags using tag expressions' do
      expect(test_case).to be_match_tags(['@a and @b'])
      expect(test_case).to be_match_tags(['@a or @d'])
      expect(test_case).to be_match_tags(['not @d'])
      expect(test_case).not_to be_match_tags(['@a and @d'])
    end

    it 'matches handles multiple expressions' do
      expect(test_case).to be_match_tags(['@a and @b', 'not @d'])
      expect(test_case).not_to be_match_tags(['@a and @b', 'not @c'])
    end
  end

  describe '#match_name?' do
    let(:name) { 'scenario' }

    it 'matches names against regexp' do
      expect(test_case).to be_match_name(/scenario/)
    end
  end

  describe '#language' do
    let(:language) { 'en-pirate' }

    it 'the language is passed when creating the test case' do
      expect(test_case.language).to eq 'en-pirate'
    end
  end

  describe 'equality' do
    it 'is equal to another test case at the same location' do
      gherkin = gherkin('features/foo.feature') do
        feature do
          scenario do
            step 'text'
          end
        end
      end
      test_case_instances = []
      receiver = double.as_null_object
      allow(receiver).to receive(:test_case) do |test_case|
        test_case_instances << test_case
      end
      2.times { compile([gherkin], receiver) }
      expect(test_case_instances.length).to eq 2
      expect(test_case_instances.uniq.length).to eq 1
      expect(test_case_instances[0]).to be_eql test_case_instances[1]
      expect(test_case_instances[0]).to eq test_case_instances[1]
      expect(test_case_instances[0]).not_to equal test_case_instances[1]
    end
  end
end
