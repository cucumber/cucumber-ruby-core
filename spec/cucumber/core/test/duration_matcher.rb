# -*- encoding: utf-8 -*-
require 'cucumber/core/test/result'
require 'rspec/expectations'

module Cucumber::Core::Test
  RSpec::Matchers.define :be_duration do |expected|
    match do |actual|
      not actual.nil? and actual.duration == expected
    end
  end

  RSpec::Matchers.define :an_unknown_duration do
    match do |actual|
      actual.nil? and expect(actual).to respond_to(:duration)
    end
  end
end
