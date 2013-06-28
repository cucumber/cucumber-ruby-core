# With thanks to @myronmarston
# https://github.com/vcr/vcr/blob/master/spec/capture_warnings.rb
require 'rubygems' if RUBY_VERSION =~ /^1\.8/
require 'rspec/core'
require 'rspec/expectations'
require 'tempfile'

stderr_file = Tempfile.new("cucumber-ruby-core.stderr")
$stderr.reopen(stderr_file.path)
current_dir = Dir.pwd

RSpec.configure do |config|
  config.after(:suite) do
    stderr_file.rewind
    lines = stderr_file.read.split("\n").uniq
    stderr_file.close!

    cucumber_core_warnings, other_warnings = lines.partition { |line| line.include?(current_dir) }

    if cucumber_core_warnings.any?
      puts
      puts "-" * 30 + " cucumber-ruby-core warnings: " + "-" * 30
      puts
      puts cucumber_core_warnings.join("\n")
      puts
      puts "-" * 75
      puts
    end

    if other_warnings.any? 
      if ENV['VIEW_OTHER_WARNINGS']
        File.open('tmp/warnings.txt', 'w') { |f| f.write(other_warnings.join("\n")) }
        puts
        puts "-" * 30 + " other warnings: " + "-" * 30
        puts
        puts other_warnings.join("\n")
        puts
        puts "-" * 75
        puts
      else
        puts "Non cucumber-ruby-core warnings hidden. To view set VIEW_OTHER_WARNINGS environment variable."
      end
    end

    # fail the build...
   raise "Failing the build because of warnings." if cucumber_core_warnings.any?
  end
end
