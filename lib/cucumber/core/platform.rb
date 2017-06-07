# frozen_string_literal: true
# Detect the platform we're running on so we can tweak behaviour
# in various places.
require 'rbconfig'

module Cucumber
  unless defined?(Cucumber::VERSION)
    JRUBY          = defined?(JRUBY_VERSION)
    IRONRUBY       = defined?(RUBY_ENGINE) && RUBY_ENGINE == "ironruby"
    WINDOWS        = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    OS_X           = RbConfig::CONFIG['host_os'] =~ /darwin/
    WINDOWS_MODERN = begin
                       ver = /^Microsoft Windows \[Version (\d+)\.(\d+)\.(\d+).*/.match(`ver`)
                       major_ver = ver[1].to_i
                       minor_ver = ver[2].to_i
                       build_ver = ver[3].to_i
                       major_ver > 10 \
                         || (major_ver == 10 && minor_ver > 0) \
                         || (major_ver == 10 && build_ver >= 15063)
                     rescue
                       false
                     end
    WINDOWS_MRI    = WINDOWS && !JRUBY && !IRONRUBY
    RUBY_2_0       = RUBY_VERSION =~ /^2\.0/
    RUBY_1_9       = RUBY_VERSION =~ /^1\.9/
  end
end
