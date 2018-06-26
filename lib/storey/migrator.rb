module Storey
  class Migrator

    def self.migrate_all(options={})
      options[:version] = options[:version].to_i if options[:version]
      self.migrate 'public', options
      Dumper.dump
      Storey.schemas(public: false).each do |schema|
        self.migrate schema, options
      end
    end

    def self.migrate(schema, options={})
      Storey.switch schema do
        puts "= Migrating #{schema}"
        active_record_migrate(options[:version])
      end
    end

    def self.run(direction, schema, version)
      Storey.switch schema do
        active_record_run(direction, version)
      end
    end

    def self.rollback_all(step=1)
      Storey.schemas.each do |schema_name|
        self.rollback(schema_name, step)
      end
      Dumper.dump
    end

    def self.rollback(schema, step=1)
      Storey.switch schema do
        puts "= Rolling back `#{schema}` #{step} steps"
        ::ActiveRecord::Migrator.rollback(
          ::ActiveRecord::Migrator.migrations_paths,
          step
        )
      end
    end

    private

    def self.active_record_migrate(version)
      if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new("5.2")
        ::ActiveRecord::Migrator.migrate(
          ::ActiveRecord::Migrator.migrations_paths,
          version,
        )
      else
        ::ActiveRecord::Tasks::DatabaseTasks.migrate
      end
    end

    def self.active_record_run(direction, target_version)
      if Gem::Version.new(ActiveRecord::VERSION::STRING) < Gem::Version.new("5.2")
        ::ActiveRecord::Migrator.run(
          direction,
          ::ActiveRecord::Migrator.migrations_paths,
          target_version
        )
      else
        ::ActiveRecord::Base.connection.migration_context.
          run(direction, target_version)
      end
    end

  end
end
