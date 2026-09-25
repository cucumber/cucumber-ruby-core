# frozen_string_literal: true

module Cucumber
  module Core
    module Test
      class NoRetries
        def will_be_retried?(_test_case, _result) = false
      end
    end
  end
end
