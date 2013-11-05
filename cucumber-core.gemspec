# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "cucumber/core/version"

Gem::Specification.new do |s|
  s.name        = 'cucumber-core'
  s.version     = Cucumber::Core::Version
  s.authors     = ["Aslak Hellesøy", "Matt Wynne", "Steve Tooke", "Oleg Sukhodolsky"]
  s.description = 'Core library for the Cucumber BDD app'
  s.summary     = "cucumber-core-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.homepage    = "http://cukes.info"
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.required_ruby_version = ">= 1.9.3"

  s.add_dependency 'gherkin', '~> 2.12.0'

  s.add_development_dependency 'bundler',   '>= 1.3.5'
  s.add_development_dependency 'rake',      '>= 0.9.2'
  s.add_development_dependency 'rspec',     '>= 2.13'
  s.add_development_dependency 'simplecov', '>= 0.6.2'
  s.add_development_dependency 'unindent',  '>= 1.0'

  # For Documentation:
  s.add_development_dependency 'bcat',     '~> 0.6.2'
  s.add_development_dependency 'kramdown', '~> 0.14'
  s.add_development_dependency 'yard',     '~> 0.8.0'

  # For coverage reports
  s.add_development_dependency 'coveralls', '~> 0.7'

  s.rubygems_version = ">= 1.6.1"
  s.files            = `git ls-files`.split("\n").reject {|path| path =~ /\.gitignore$/ }
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
