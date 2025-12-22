# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |s|
  s.name        = 'cucumber-core'
  s.version     = version
  s.authors     = ['Aslak Hellesøy', 'Matt Wynne', 'Steve Tooke', 'Oleg Sukhodolsky', 'Tom Brand']
  s.description = 'Core library for the Cucumber BDD app'
  s.summary     = "cucumber-core-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.homepage    = 'https://cucumber.io'
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.2'
  s.required_rubygems_version = '>= 3.2.8'

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/cucumber/cucumber-ruby-core/issues',
    'changelog_uri' => 'https://github.com/cucumber/cucumber-ruby-core/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://www.rubydoc.info/github/cucumber/cucumber-ruby-core',
    'mailing_list_uri' => 'https://groups.google.com/forum/#!forum/cukes',
    'source_code_uri' => 'https://github.com/cucumber/cucumber-ruby-core',
    'funding_uri' => 'https://opencollective.com/cucumber'
  }

  s.add_dependency 'cucumber-gherkin', '> 36', '< 40'
  s.add_dependency 'cucumber-messages', '> 31', '< 33'
  s.add_dependency 'cucumber-tag-expressions', '> 6', '< 9'

  s.add_development_dependency 'rake', '~> 13.3'
  s.add_development_dependency 'rspec', '~> 3.13'
  s.add_development_dependency 'rubocop', '~> 1.81.0'
  s.add_development_dependency 'rubocop-packaging', '~> 0.6.0'
  s.add_development_dependency 'rubocop-rake', '~> 0.7.0'
  s.add_development_dependency 'rubocop-rspec', '~> 3.8.0'

  s.files            = Dir['CHANGELOG.md', 'README.md', 'LICENSE', 'lib/**/*']
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_path     = 'lib'
end
