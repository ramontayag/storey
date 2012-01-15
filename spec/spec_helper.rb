# NOTE: When run all together, not all tests pass. That's because when schema.rb
# rewritten and no longer reflects the actual state of the database schema,
# new postgresql schemas that are created don't have all the tables either.
# Trying to create items in those tables with blow up the tests.
#
# What the plan?
#
# Perhaps it would be wise to save the schema.rb to schema-backup.rb
# the first time that schema.rb is created. schema-backup.rb isn't rewritten
# by the tests as they run. But we use this to schema-backup.rb to overwrite
# schema.rb for each test.

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

# So we can clean the database before each test
require 'database_cleaner'

# Include rake so we can instantiate the @rake variable and call rake tasks
require 'rake'

RSpec.configure do |config|
  config.before(:each) do
    # If for some reason public schema doesn't exist, create it
    #Storey.create("public", :load_database_schema => false) unless Storey.schemas.include?("public")
    #puts "Just created public: #{Storey.schemas.inspect}"

    # We don't want configuration to leak into other tests
    #puts "Reloading config"
    Storey.reload_config!

    # Always switch back to the default search path
    # Some tests that didn't switch back broke the following tests
    #puts "Switching to public!"
    Storey.switch

    # Delete all schemas except public
    #puts "About to iterate through schemas to drop all except public..."
    Storey.schemas(:public => false).each do |schema|
      puts "Dropping: #{schema}"
      Storey.drop schema
    end

    # How to call rake from within your app:
    # http://www.philsergi.com/2009/02/testing-rake-tasks-with-rspec.html
    #puts "Making @rake"
    @rake = Rake::Application.new
    #puts "Rake.application = @rake"
    Rake.application = @rake
    #puts "Dummy::Application.load_tasks"
    Dummy::Application.load_tasks

    # It seems when instantiating our own rake object, misc.rake
    # isn't loaded. We get the following error if we don't load misc.rake:
    # RuntimeError: Don't know how to build task 'rails_env'
    load "rails/tasks/misc.rake"

    # Migrate the public schema
    #puts "About to switch to public to migrate"
    #Storey.switch do
      #puts "about to migrate in: #{Storey.schema}"
      #@rake["db:drop"].invoke
      #@rake["db:create"].invoke
      @rake["db:migrate"].invoke
      #@rake["db:schema:dump"].invoke
    #end

    #puts "About to clean #{Storey.schema} schema"
    # Clean public schema
    #Storey.switch do
      #DatabaseCleaner.clean_with :truncation
      #[Company, Post].each do |klass|
        #klass.destroy_all
      #end
    #end
  end
end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
