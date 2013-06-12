dummy_migrations_path = File.join(File.dirname(__FILE__), '..', '..', 'db', 'migrate')
ActiveRecord::Migrator.migrations_path = dummy_migrations_path
