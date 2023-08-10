# -*- encoding: utf-8 -*-
version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |s|
  s.name        = 'cucumber-core'
  s.version     = version
  s.authors     = ["Aslak Hellesøy", "Matt Wynne", "Steve Tooke", "Oleg Sukhodolsky", "Tom Brand"]
  s.description = 'Core library for the Cucumber BDD app'
  s.summary     = "cucumber-core-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.homepage    = "https://cucumber.io"
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.required_ruby_version = '>= 2.3' # Keep in sync with .travis.yml

  s.metadata    = {
                    'bug_tracker_uri' => 'https://github.com/cucumber/cucumber-ruby-core/issues',
                    'changelog_uri'   => 'https://github.com/cucumber/cucumber-ruby-core/blob/master/CHANGELOG.md',
                    'documentation_uri' => 'https://www.rubydoc.info/github/cucumber/cucumber-ruby-core',
                    'mailing_list_uri'  => 'https://groups.google.com/forum/#!forum/cukes',
                    'source_code_uri' => 'https://github.com/cucumber/cucumber-ruby-core',
                  }

  s.add_dependency 'cucumber-gherkin', '>= 24', '< 27'
  s.add_dependency 'cucumber-messages', '>= 19', '< 22'
  s.add_dependency 'cucumber-tag-expressions', '~> 5.0', '>= 5.0.4'

  s.add_development_dependency 'rake', '~> 13.0', '>= 13.0.6'
  s.add_development_dependency 'rspec', '~> 3.11', '>= 3.11.0'
  s.add_development_dependency 'rubocop', '~> 1.29', '>= 1.29.1'
  s.add_development_dependency 'rubocop-packaging', '~> 0.5', '>= 0.5.1'
  s.add_development_dependency 'unindent', '~> 1.0', '>= 1.0'

  s.files            = Dir[
    'CHANGELOG.md',
    'CONTRIBUTING.md',
    'README.md',
    'LICENSE',
    'lib/**/*'
  ]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
