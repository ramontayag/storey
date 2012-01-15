module Storey::Migrator
  extend self

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

  def rollback(schema, step=1)
    Storey.switch schema do
      ActiveRecord::Migrator.rollback(
        ActiveRecord::Migrator.migrations_path,
        step
      )
    end
  end
end
