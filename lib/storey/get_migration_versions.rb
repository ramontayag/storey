module Storey
  class GetMigrationVersions

    def self.call(schema = nil)
      return migration_versions if schema.nil?
      Storey.switch(schema) { migration_versions }
    end

    private

    def self.migration_versions
      if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new("5.2")
        ::ActiveRecord::Migrator.get_all_versions
      else
        ::ActiveRecord::Base.connection.migration_context.
          get_all_versions
      end
    end

  end
end
