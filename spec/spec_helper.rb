# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

# So we can clean the database before each test
require 'database_cleaner'

# Include rake so we can instantiate the @rake variable and call rake tasks
require 'rake'

require 'pry'

RSpec.configure do |config|
  config.before(:suite) do
    # Clean the public schema
    Storey.switch do
      tables = ActiveRecord::Base.connection.tables
      # Don't invoke DatabaseCleaner if there are no tables,
      # since that library chokes and tries to drop tables without names
      if tables.size != 1 or tables[0] != 'schema_migrations'
        DatabaseCleaner.clean_with :truncation
      end
    end
  end

  config.before(:each) do
    # We don't want configuration to leak into other tests
    Storey.reload_config!

    # Always switch back to the default search path
    # Some tests that didn't switch back broke the following tests
    Storey.switch

    # Delete all schemas except public
    Storey.schemas(:public => false, :suffix => true).each do |schema|
      Storey.drop schema
    end

    # How to call rake from within your app:
    # http://www.philsergi.com/2009/02/testing-rake-tasks-with-rspec.html
    @rake = Rake::Application.new
    Rake.application = @rake
    Dummy::Application.load_tasks

    # It seems when instantiating our own rake object, misc.rake
    # isn't loaded. We get the following error if we don't load misc.rake:
    # RuntimeError: Don't know how to build task 'rails_env'
    load "rails/tasks/misc.rake"

    # we don't want any test that has set this to keep it hanging around
    # screwing with our migration
    ENV['STEP'] = ENV['VERSION'] = nil
    Rails.application.config.active_record.schema_format = :ruby
    @rake["db:migrate"].invoke
  end
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
