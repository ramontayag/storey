module Storey
  module Migrator

    extend self

    def migrate_all(options={})
      options[:version] = options[:version].to_i if options[:version]
      self.migrate 'public', options
      Dumper.dump
      Storey.schemas(public: false).each do |schema|
        self.migrate schema, options
      end
    end

    def migrate(schema, options={})
      Storey.switch schema do
        puts "= Migrating #{schema}"
        ::ActiveRecord::Migrator.migrate(::ActiveRecord::Migrator.migrations_path,
                                         options[:version])
      end
    end

    def run(direction, schema, version)
      Storey.switch schema do
        ::ActiveRecord::Migrator.run(
          direction,
          ::ActiveRecord::Migrator.migrations_path,
          version
        )
      end
    end

    def rollback_all(step=1)
      Storey.schemas.each do |schema_name|
        self.rollback(schema_name, step)
      end
      Dumper.dump
    end

    def rollback(schema, step=1)
      Storey.switch schema do
        puts "= Rolling back `#{schema}` #{step} steps"
        ::ActiveRecord::Migrator.rollback(
          ::ActiveRecord::Migrator.migrations_path,
          step
        )
      end
    end

  end
end
