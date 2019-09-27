source "https://rubygems.org"

if ENV['GHERKIN_RUBY_REPO']
  gem 'gherkin', git: ENV['GHERKIN_RUBY_REPO']
elsif ENV['GHERKIN_RUBY']
  gem 'gherkin', path: ENV['GHERKIN_RUBY']
end

if ENV['CUCUMBER_MESSAGES_RUBY_REPO']
  gem 'cucumber-messages', git: ENV['CUCUMBER_MESSAGES_RUBY_REPO']
elsif ENV['CUCUMBER_MESSAGES_RUBY']
  gem 'cucumber-messages', path: ENV['CUCUMBER_MESSAGES_RUBY']
end


# Use an older protobuf on JRuby and MRI < 2.5
gem 'google-protobuf', '~> 3.2.0.2' if RbConfig::CONFIG['MAJOR'].to_i == 2 && RbConfig::CONFIG['MINOR'].to_i < 5 || RUBY_PLATFORM == 'java'

gemspec
