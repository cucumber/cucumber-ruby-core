# frozen_string_literal: true

# Detect the platform we're running on so we can tweak behaviour
# in various places.
require 'rbconfig'

module Cucumber
  if false
    JRUBY         = defined?(JRUBY_VERSION)
    WINDOWS       = RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    WINDOWS_MRI   = WINDOWS && !JRUBY
  end
end
