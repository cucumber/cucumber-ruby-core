# With thanks to @myronmarston
# http://myronmars.to/n/dev-blog/2011/08/making-your-gem-warning-free
require 'tempfile'
stderr_file = Tempfile.new("cucumber-ruby-core.stderr")
$stderr.reopen(stderr_file.path)
current_dir = Dir.pwd

at_exit do
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
    File.open('tmp/warnings.txt', 'w') { |f| f.write(other_warnings.join("\n")) }
    puts
    puts "Non-cucumber-ruby-core warnings written to tmp/warnings.txt"
    puts
  end

  # fail the build...
  exit(1) if cucumber_core_warnings.any?
end
