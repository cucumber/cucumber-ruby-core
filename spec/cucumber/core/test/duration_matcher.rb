# -*- encoding: utf-8 -*-
require 'cucumber/core/test/result'
require 'rspec/expectations'

module Cucumber::Core::Test
  RSpec::Matchers.define :be_duration do |expected|
    match do |actual|
      actual.exist? and actual.duration == expected
    end
  end  

  RSpec::Matchers.alias_matcher :a_duration_of, :be_duration

  RSpec::Matchers.define :an_unknown_duration do
    match do |actual|
      not actual.exist? and expect(actual).to respond_to(:duration)
    end
  end  
end
