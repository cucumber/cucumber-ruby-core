# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "cucumber/core/version"

Gem::Specification.new do |s|
  s.name        = 'cucumber-core'
  s.version     = Cucumber::Core::Version
  s.authors     = ["Aslak Hellesøy", "Matt Wynne", "Steve Tooke", "Oleg Sukhodolsky", "Tom Brand"]
  s.description = 'Core library for the Cucumber BDD app'
  s.summary     = "cucumber-core-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.homepage    = "https://cucumber.io"
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.required_ruby_version = '>= 2.2' # Keep in sync with .travis.yml

  s.metadata    = {
                    'bug_tracker_uri' => 'https://github.com/cucumber/cucumber-ruby-core/issues',
                    'changelog_uri'   => 'https://github.com/cucumber/cucumber-ruby-core/blob/master/CHANGELOG.md',
                    'documentation_uri' => 'https://www.rubydoc.info/github/cucumber/cucumber-ruby-core',
                    'mailing_list_uri'  => 'https://groups.google.com/forum/#!forum/cukes',
                    'source_code_uri' => 'https://github.com/cucumber/cucumber-ruby-core',
                  }

  s.add_dependency 'gherkin', '~> 7.0', '>= 7.0.3'
  s.add_dependency 'cucumber-tag_expressions', '~> 2.0', '>= 2.0.2'
  s.add_dependency 'backports', '~> 3.15', '>= 3.15.0'

  s.add_development_dependency 'bundler', '~> 2.0', '>= 2.0.2'
  s.add_development_dependency 'rake', '~> 12.3', '>= 12.3.3'
  s.add_development_dependency 'rspec', '~> 3.8', '>= 3.8.0'
  s.add_development_dependency 'unindent', '~> 1.0', '>= 1.0'

  s.rubygems_version = ">= 1.6.1"
  s.test_files            = Dir[
    'spec/**/*'
  ]
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
