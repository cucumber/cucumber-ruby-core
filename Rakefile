# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

$:.unshift File.expand_path("../lib", __FILE__)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

namespace :spec do
  desc "run (slow) performance tests"
  RSpec::Core::RakeTask.new(:slow) do |t|
    t.rspec_opts = %w[--tag slow]
  end
end

task default: ['spec', 'spec:slow', 'rubocop']
