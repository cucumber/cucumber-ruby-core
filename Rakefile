# encoding: utf-8
require 'rubygems'
require 'bundler'
Bundler::GemHelper.install_tasks

$:.unshift File.expand_path("../lib", __FILE__)

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.ruby_opts  = %w[-r./spec/coverage -w]
  t.rspec_opts = %w[--color]
end

namespace :integration do
  cucumber_ruby_core_folder = Dir.pwd

  task :spec => [:pull_cucumber] do
    sh "rake build"
    cd "_tmp"
    sh "bundle config local.cucumber-core #{cucumber_ruby_core_folder}"
    sh "bundle install --path=vendor"
    sh "bundle exec rake"
  end

  task :pull_cucumber => "_tmp" do
    puts "Pulling in changes"
    sh "cd _tmp && git pull &>/dev/null"
  end

  directory "_tmp" do
    puts "Cloning a new repo"
    sh "git clone git://github.com/cucumber/cucumber.git _tmp"
  end
end

require_relative 'spec/capture_warnings'
include CaptureWarnings
namespace :spec do
  task :warnings do
    report_warnings do
      Rake::Task[:spec].invoke
    end

    unless $!
      capture_error do
        Rake::Task['integration:spec'].invoke
      end
    end
  end
end

task default: ['spec:warnings']

desc "Run the full suite of cucumber-ruby-core and cucumber/cucumber"
task full_spec: :default
