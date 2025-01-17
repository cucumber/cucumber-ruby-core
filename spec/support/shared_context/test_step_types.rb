# frozen_string_literal: true

require 'cucumber/core/test/step'

RSpec.shared_context 'with different types of test steps' do
  let(:passing_step)   { Cucumber::Core::Test::Step.new(1, 'Passing Step', double).with_action { :no_op } }
  let(:failing_step)   { Cucumber::Core::Test::Step.new(2, 'Failing Step', double).with_action { raise StandardError, 'Error' } }
  let(:pending_step)   { Cucumber::Core::Test::Step.new(3, 'Pending Step', double).with_action { raise Cucumber::Core::Test::Result::Pending, 'TODO' } }
  let(:skipping_step)  { Cucumber::Core::Test::Step.new(4, 'Skipped Step', double).with_action { raise Cucumber::Core::Test::Result::Skipped } }
  let(:undefined_step) { Cucumber::Core::Test::Step.new(5, 'Undefined Step', double) }
end
