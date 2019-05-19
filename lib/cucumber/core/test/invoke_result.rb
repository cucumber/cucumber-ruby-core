module Cucumber
  module Core
    module Test
      class InvokeResult
        attr_reader :embeddings
        def initialize(embeddings = [])
          @embeddings = embeddings
        end
      end

      class PassedInvokeResult < InvokeResult
      end

      class FailedInvokeResult < InvokeResult
        attr_reader :exception
        def initialize(exception, embeddings = [])
          super(embeddings)
          @exception = exception
        end
      end
    end
  end
end
