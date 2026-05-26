# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        # Flaky is not used directly as an execution result, but is used as a
        # reporting result type for test cases that fails and the passes on
        # retry, therefore only the class method self.ok? is needed.
        class Flaky
          def self.ok?
            false
          end
        end
      end
    end
  end
end
