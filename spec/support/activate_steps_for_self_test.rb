# frozen_string_literal: true

# This filter is used for testing Cucumber itself. It adds step definitions that
# will activate steps to have passed / failed / pending results if they use expected names.
class ActivateStepsForSelfTest < Cucumber::Core::Filter.new
  Failure = Class.new(StandardError)

  def test_case(test_case)
    test_case.with_steps(test_steps(test_case)).describe_to(receiver)
  end

  private

  def test_steps(test_case)
    test_case.test_steps.map do |step|
      case step.text
      when /fail/ then step.with_action { raise Failure }
      when /pending/ then step.with_action { raise Test::Result::Pending }
      when /pass/ then step.with_action { :no_op }
      else; step
      end
    end
  end
end
