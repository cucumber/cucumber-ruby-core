source "https://rubygems.org"

gem 'gherkin', path: ENV['GHERKIN_RUBY'] if ENV['GHERKIN_RUBY']

gem 'cucumber-messages', path: ENV['CUCUMBER_MESSAGES_RUBY'] if ENV['CUCUMBER_MESSAGES_RUBY']

# Use an older protobuf on JRuby and MRI < 2.5
gem 'google-protobuf', '~> 3.2.0.2' if RbConfig::CONFIG['MAJOR'].to_i == 2 && RbConfig::CONFIG['MINOR'].to_i < 5 || RUBY_PLATFORM == 'java'

gemspec
