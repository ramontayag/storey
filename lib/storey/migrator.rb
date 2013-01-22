module Storey::Migrator
  extend self

  def migrate_all
    self.migrate 'public'
    Storey::Dumper.dump
    Storey.schemas(public: false).each do |schema|
      self.migrate schema
    end
  end

  def migrate(schema)
    Storey.switch schema do
      ActiveRecord::Migrator.migrate ActiveRecord::Migrator.migrations_path
    end
  end

  def run(direction, schema, version)
    Storey.switch schema do
      ActiveRecord::Migrator.run(
        direction,
        ActiveRecord::Migrator.migrations_path,
        version
      )
    end
  end

  def rollback_all(step=1)
    Storey.schemas.each do |schema_name|
      puts "rolling back #{schema_name}"
      self.rollback(schema_name, step)
    end
  end

  def rollback(schema, step=1)
    Storey.switch schema do
      ActiveRecord::Migrator.rollback(
        ActiveRecord::Migrator.migrations_path,
        step
      )
    end
  end
end
