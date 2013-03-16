module Storey
  class Hstore

    def self.install
      self.new.install
    end

    def install
      ensure_hstore_is_persistent
      Storey.create 'hstore', force: true
      ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS hstore SCHEMA #{suffixify('hstore')}"
    rescue ActiveRecord::StatementInvalid => e
      if e.message =~ /could not open extension control file/
        fail StoreyError, "Oops! Looks like the Hstore extension is not installed. Please install it for your OS first."
      end
      fail e
    end

    private

    def ensure_hstore_is_persistent
      unless Storey.persistent_schemas.include?('hstore')
        fail StoreyError, 'You are attempting to install hstore data type, but the hstore schema (where the data type will be installed) is not one of the persistent schemas. Please add hstore to the list of persistent schemas.'
      end
    end

    def suffixify(schema_name)
      Suffixifier.suffixify(schema_name)
    end

  end
end
