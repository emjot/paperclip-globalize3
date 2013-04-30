require 'bundler/setup'
require 'appraisal'
require 'rspec/core/rake_task'

require 'bundler/gem_tasks'

desc 'Default: run all tests with all supported versions'
task :default => :all

desc 'Run tests with all supported Rails versions.'
task :all => ["appraisal:install"] do
  exec('rake appraisal spec')
end

desc 'Run all tests'
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = FileList['spec/**/*_spec.rb']
end
