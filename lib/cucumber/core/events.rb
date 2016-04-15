require 'cucumber/core/events/bus'
require 'cucumber/core/events/event'

module Cucumber
  module Core
    module Events
      TestCaseStarting = Event.new(:test_case)
      TestStepStarting = Event.new(:test_step)
      TestStepFinished = Event.new(:test_step, :result)
      TestCaseFinished = Event.new(:test_case, :result)
    end
  end
end
