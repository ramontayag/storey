class Storey::Hstore
  Storey.create 'hstore'
  ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS hstore SCHEMA #{Storey.suffixify('hstore')}"
end
