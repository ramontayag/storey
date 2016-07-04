dummy_migrations_paths = File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate')
ActiveRecord::Migrator.migrations_paths = dummy_migrations_paths
