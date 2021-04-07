source "https://rubygems.org"

def monorepo(name)
  return {} if ENV['CUCUMBER_RELEASED_GEMS']
  path = "../../cucumber/#{name}/ruby"
  if File.directory?(path)
    { path: File.expand_path(path) }
  else
    { git: "https://github.com/cucumber/cucumber.git", glob: "#{name}/ruby/cucumber-#{name}.gemspec" }
  end
end

gem 'cucumber-gherkin', monorepo('gherkin')
gem 'cucumber-messages', monorepo('messages')
gem 'cucumber-tag-expressions', monorepo('tag-expressions')

gemspec
