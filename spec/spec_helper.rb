require 'fileutils'
require 'logger'
require 'pathname'
require 'rspec'
require 'active_record'
require 'active_support'
require 'database_cleaner'

ROOT = Pathname(File.expand_path(File.join(File.dirname(__FILE__), '..')))
TEST_ASSETS_PATH = Pathname.new(ROOT).join('tmp', 'public')

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/paperclip-globalize3'))

ActiveRecord::Base.send(:include, Paperclip::Glue)

Paperclip.interpolates(:test_env_number) do |_, _|
  ENV['TEST_ENV_NUMBER'].presence || '0'
end

tmpdir = File.join(File.dirname(__FILE__), '../tmp')
FileUtils.mkdir(tmpdir) unless File.exist?(tmpdir)
log = File.expand_path(File.join(tmpdir, 'globalize3_test.log'))
FileUtils.touch(log) unless File.exist?(log)
ActiveRecord::Base.logger = Logger.new(log)
ActiveRecord::LogSubscriber.attach_to(:active_record)
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
if ActiveRecord::VERSION::STRING >= '4.2' &&
   ActiveRecord::VERSION::STRING < '5.0'
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end
Paperclip.options[:logger] = ActiveRecord::Base.logger

require File.expand_path('../data/schema', __FILE__)
require File.expand_path('../data/models', __FILE__)
DatabaseCleaner.strategy = :truncation # we need to commit transactions so that after_commit callbacks are executed

I18n.available_locales = %i[en de]

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!

  config.default_formatter = 'doc' if config.files_to_run.one?

  config.profile_examples = 2
  config.order = :random
  Kernel.srand config.seed

  config.before(:each) do
    DatabaseCleaner.start
    I18n.locale = I18n.default_locale = :en
    Globalize.locale = nil
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:all) do
    FileUtils.rm_rf TEST_ASSETS_PATH if File.exist?(TEST_ASSETS_PATH)
  end
end
