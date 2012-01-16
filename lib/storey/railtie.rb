#require 'rails'
class Storey::Railtie < Rails::Railtie
  #
  #   Set up our default config options
  #   Do this before the app initializers run so we don't override custom settings
  #
  #config.before_initialize do
    #Storey.configure do |config|
      #config.excluded_models = []
      #config.use_postgres_schemas = true
      #config.database_names = []
      #config.seed_after_create = false
      #config.prepend_environment = true
    #end
  #end

  # @bradrobertson's note in Apartment:
  # Hook into ActionDispatch::Reloader to ensure Storey is properly initialized
  # Note that this doens't entirely work as expected in Development, because this is called before classes are reloaded
  # See the above middleware/console declarations below to help with this.  Hope to fix that soon.
  config.to_prepare do
    Storey.init
  end

  # Load Storey's rake tasks
  rake_tasks do
    load 'tasks/storey.rake'
  end

  #
  #   The following initializers are a workaround to the fact that I can't properly hook into the rails reloader
  #   Note this is technically valid for any environment where cache_classes is false, for us, it's just development
  #
  #if Rails.env.development?

    # Storey::Reloader is middleware to initialize things properly on each request to dev
    #initializer 'storey.init' do |app|
      #app.config.middleware.use "Storey::Reloader"
    #end

    # Overrides reload! to also call Storey::Database.init as well so that the reloaded classes have the proper table_names
    #console do
      #require 'storey/console'
    #end

  #end
end
