# frozen_string_literal: true

require 'cucumber/core/test/step'
require_relative 'test_step_types'

RSpec.shared_context 'with different types of test cases' do
  include_context 'with different types of test steps'

  let(:passing_test_case) { Cucumber::Core::Test::Case.new(1, 'Passing Test', [passing_step], double, double, [], 'en', []) }
  let(:failing_test_case) { Cucumber::Core::Test::Case.new(2, 'Failing Test', [failing_step], double, double, [], 'en', []) }
  let(:pending_test_case) { Cucumber::Core::Test::Case.new(3, 'Pending Test', [pending_step], double, double, [], 'en', []) }
end
