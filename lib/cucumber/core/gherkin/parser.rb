# frozen_string_literal: true
require 'gherkin/gherkin'

module Cucumber
  module Core
    module Gherkin
      ParseError = Class.new(StandardError)

      class Parser
        attr_reader :receiver, :event_bus
        private     :receiver, :event_bus

        def initialize(receiver, event_bus)
          @receiver = receiver
          @event_bus = event_bus
        end

        def document(document)
          messages = ::Gherkin::Gherkin.from_source(document.uri, document.body, {default_dialect: document.language, include_source: false})
          messages.each do |message|
            if !message.gherkinDocument.nil?
              event_bus.gherkin_source_parsed(message.gherkinDocument)
            elsif !message.pickle.nil?
              receiver.pickle(message.pickle)
            elsif !message.attachment.nil?
              # Parse error
              raise Core::Gherkin::ParseError.new("#{document.uri}: #{message.attachment.data}")
            else
              raise "Unknown message: #{message.to_hash}"
            end
          end
        end

        def done
          receiver.done
          self
        end
      end
    end
  end
end
