# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

$:.unshift File.expand_path("../lib", __FILE__)

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts  = %w[-r./spec/capture_warnings -r./spec/coverage]
  t.rspec_opts = %w[--color --warnings]
end

task default: [:spec]
