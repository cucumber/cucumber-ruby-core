# frozen_string_literal: true

require 'cucumber/core/test/step'

RSpec.shared_context "steps" do
  let(:passing)          { Cucumber::Core::Test::Step.new(1, 'Passing Step', double).with_action { :no_op } }
  let(:failing)          { Cucumber::Core::Test::Step.new(2, 'Failing Step', double).with_action { raise StandardError, 'Error' } }
  let(:pending)          { Cucumber::Core::Test::Step.new(3, 'Pending Step', double).with_action { raise Cucumber::Core::Test::Result::Pending, 'TODO' } }
  let(:skipping)         { Cucumber::Core::Test::Step.new(4, 'Skipped Step', double).with_action { raise Cucumber::Core::Test::Result::Skipped } }
  let(:undefined)        { Cucumber::Core::Test::Step.new(5, 'Undefined Step', double) }
end
