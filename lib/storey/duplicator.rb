class Storey::Duplicator
  attr_accessor :source_schema, :target_schema, :source_file, :target_file, :structure_only, :file_prefix, :dump_path, :source_dump_path, :target_dump_path

  def initialize(from_schema, to_schema, options={})
    self.dump_path = File.join Rails.root, 'tmp', 'schema_dumps'
    self.source_dump_path = File.join self.dump_path, 'source'
    self.target_dump_path = File.join self.dump_path, 'target'
    self.structure_only = options[:structure_only] || false

    self.source_schema = Storey.suffixify from_schema
    self.target_schema = Storey.suffixify to_schema
    self.file_prefix = "#{Time.now.to_i}_#{rand(100000)}"
    self.source_file   = File.join self.source_dump_path, "#{self.file_prefix}_#{self.source_schema}.sql"
    self.target_file   = File.join self.target_dump_path, "#{self.file_prefix}_#{self.target_schema}.sql"
  end

  def perform!
    dump_schema
    replace_occurances
    load_schema
  end

  private

  def dump_schema(options={})
    ENV['PGPASSWORD'] = Storey.database_config[:password]
    prepare_schema_dump_directories

    options[:host]     ||= Storey.database_config[:host] unless Storey.database_config[:host].blank?
    options[:username] ||= Storey.database_config[:username]
    options[:file]     ||= self.source_file
    options[:schema]   ||= self.source_schema

    switches = options.map { |k, v| "--#{k}=#{v}" }
    switches << '--schema-only' if self.structure_only
    switches = switches.join(" ")

    `pg_dump #{switches} #{Storey.database_config[:database]}`
  end

  def prepare_schema_dump_directories
    [self.source_dump_path, self.target_dump_path].each { |d| FileUtils.mkdir_p(d) }
  end

  def load_schema(options={})
    options[:host]     ||= Storey.database_config[:host] unless Storey.database_config[:host].blank?
    options[:dbname]   ||= Storey.database_config[:database]
    options[:username] ||= Storey.database_config[:username]
    options[:file] ||= self.target_file

    switches = options.map { |k, v| "--#{k}=#{v}" }.join(" ")

    if duplicating_from_default?
      # Since we are copying the source schema and we're after structure only,
      # the dump_schema ended up creating a SQL file without the "CREATE SCHEMA" command
      # thus we have to create it manually
      ::Storey.create_plain_schema self.target_schema
    end

    source_schema_migrations = ::Storey.switch(self.source_schema) do
      ActiveRecord::Migrator.get_all_versions
    end

    `psql #{switches}`

    ::Storey.switch self.target_schema do
      source_schema_migrations.each do |version|
        ActiveRecord::Base.connection.execute "INSERT INTO schema_migrations (version) VALUES ('#{version}');"
      end
    end

    ENV['PGPASSWORD'] = nil
  end

  def replace_occurances
    File.open(self.source_file, 'r') do |file|
      file.each_line do |line|
        new_line = line.gsub(/#{self.source_schema}/, self.target_schema)
        File.open(self.target_file, 'a') {|tf| tf.puts new_line}
      end
    end
  end

  def duplicating_from_default?
    ::Storey.matches_default_search_path?(self.source_schema) && self.structure_only
  end
end
