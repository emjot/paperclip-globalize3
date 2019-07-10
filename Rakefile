# frozen_string_literal: true

require 'bundler/setup'
require 'paperclip/globalize3/gem_tasks'
require 'appraisal'
require 'rspec/core/rake_task'
require 'wwtd/tasks'

desc 'Default: run all tests with all supported versions'
task default: :all

desc 'Run tests with all supported Rails versions.'
task all: ['appraisal:install'] do
  exec('rake appraisal spec')
end

task local: 'wwtd:local' # run all gemfiles with local ruby

desc 'Run all tests'
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end
