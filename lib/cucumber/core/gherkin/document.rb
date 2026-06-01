# frozen_string_literal: true

module Cucumber
  module Core
    module Gherkin
      class Document
        attr_reader :uri, :body, :language

        def initialize(uri, body, language = nil)
          @uri = uri
          @body = body
          @language = language || 'en'
        end

        def ==(other)
          to_s == other.to_s
        end

        def to_s
          body
        end

        def to_envelope
          Cucumber::Messages::Envelope.new(
            source: Cucumber::Messages::Source.new(
              uri: uri,
              data: body,
              media_type: 'text/x.cucumber.gherkin+plain'
            )
          )
        end
      end
    end
  end
end
