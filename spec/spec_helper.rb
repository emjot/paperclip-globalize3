require 'pathname'
require 'fileutils'

ROOT = Pathname(File.expand_path(File.join(File.dirname(__FILE__), '..')))
TEST_ASSETS_PATH = Pathname.new(ROOT).join('tmp', 'public')

RSpec.configure do |config|
  config.mock_with :rspec
  config.after(:suite) do
    FileUtils.rm_rf TEST_ASSETS_PATH if File.exist?(TEST_ASSETS_PATH)
  end
end

require 'active_support'
require 'action_pack'
require 'action_view'
require 'action_controller'
require 'action_dispatch'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/paperclip-globalize3'))

ActiveRecord::Base.send(:include, Paperclip::Glue)

# set up globalize3 and models (borrowed from globalize3)
require 'fileutils'
require 'logger'
tmpdir = File.join(File.dirname(__FILE__), "../tmp")
FileUtils.mkdir(tmpdir) unless File.exist?(tmpdir)
log = File.expand_path(File.join(tmpdir, "globalize3_test.log"))
FileUtils.touch(log) unless File.exists?(log)
ActiveRecord::Base.logger = Logger.new(log)
ActiveRecord::LogSubscriber.attach_to(:active_record)
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
require File.expand_path('../data/schema', __FILE__)
require File.expand_path('../data/models', __FILE__)
I18n.locale = I18n.default_locale = :en
Globalize.locale = nil
