RSpec.shared_context "steps" do
  let(:passing)          { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { :no_op } }
  let(:failing)          { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { raise exception } }
  let(:pending)          { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { raise Cucumber::Core::Test::Result::Pending, 'TODO' } }
  let(:skipping)         { Cucumber::Core::Test::Step.new(double, text, double, double).with_action { raise Cucumber::Core::Test::Result::Skipped } }
  let(:undefined)        { Cucumber::Core::Test::Step.new(double, text, double, double) }

  let(:text)             { 'Step Name' }
  let(:exception)        { StandardError.new('test error') }
end
