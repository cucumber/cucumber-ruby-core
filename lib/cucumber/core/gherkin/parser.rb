# frozen_string_literal: true
require 'gherkin'
require 'cucumber/core/gherkin/location_query'

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
          @location_query = LocationQuery.new
        end

        def document(document)
          messages = ::Gherkin.from_source(document.uri, document.body, gherkin_options(document))
          messages.each do |message|
            @location_query.process(message)
            if !message.gherkin_document.nil?
              event_bus.gherkin_source_parsed(message.gherkin_document)
              event_bus.envelope(message)
            elsif !message.pickle.nil?
              receiver.pickle(message.pickle, @location_query)
              event_bus.envelope(message)
            elsif !message.attachment.nil?
              # Parse error
              raise Core::Gherkin::ParseError.new("#{document.uri}: #{message.attachment.text}")
            else
              raise "Unknown message: #{message.to_hash}"
            end
          end
        end

        def gherkin_options(document)
          {
            default_dialect: document.language,
            include_source: false,
            include_gherkin_document: true,
            include_pickles: true
          }
        end

        def done
          receiver.done
          self
        end
      end
    end
  end
end
