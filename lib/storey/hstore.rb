class Storey::Hstore
  def self.install
    fail Storey::StoreyError, 'You are attempting to install hstore data type, but the hstore schema (where the data type will be installed) is not one of the persistent schemas. Please add hstore to the list of persistent schemas.' unless Storey.persistent_schemas.include?('hstore')

    Storey.create 'hstore', force: true
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS hstore SCHEMA #{Storey.suffixify('hstore')}"
  end
end
