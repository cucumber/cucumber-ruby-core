# frozen_string_literal: true

require 'cucumber/core/test/empty_multiline_argument'

describe Cucumber::Core::Test::EmptyMultilineArgument do
  describe '#data_table?' do
    it { is_expected.not_to be_data_table }
  end

  describe '#doc_string' do
    it { is_expected.not_to be_doc_string }
  end
end
