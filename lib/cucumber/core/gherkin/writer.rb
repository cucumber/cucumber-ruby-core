# frozen_string_literal: true

require_relative 'document'

require_relative 'writer/helpers'

require_relative 'writer/gherkin'
require_relative 'writer/feature'
require_relative 'writer/background'
require_relative 'writer/rule'
require_relative 'writer/scenario'
require_relative 'writer/example'
require_relative 'writer/scenario_outline'
require_relative 'writer/step'
require_relative 'writer/table'
require_relative 'writer/doc_string'
require_relative 'writer/examples'

module Cucumber
  module Core
    module Gherkin
      module Writer
        def gherkin(uri = 'features/test.feature', &)
          Gherkin.new(uri, &).build
        end
      end
    end
  end
end
