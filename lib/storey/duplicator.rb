module Storey
  class Duplicator

    attr_accessor(:source_schema,
                  :target_schema,
                  :source_file,
                  :target_file,
                  :structure_only,
                  :file_prefix,
                  :dump_path,
                  :source_dump_path,
                  :target_dump_path)

    def initialize(from_schema, to_schema, options={})
      unless from_schema
        fail SchemaNotFound, "cannot duplicate from nil schema"
      end

      self.dump_path = File.join Rails.root, 'tmp', 'schema_dumps'
      self.source_dump_path = File.join self.dump_path, 'source'
      self.target_dump_path = File.join self.dump_path, 'target'
      self.structure_only = options[:structure_only] || false

      self.source_schema = suffixify(from_schema)
      self.target_schema = suffixify(to_schema)
      self.file_prefix = "#{Time.now.to_i}_#{rand(100000)}"
      self.source_file = File.join(
        self.source_dump_path,
        "#{self.file_prefix}_#{self.source_schema}.sql"
      )
      self.target_file = File.join(
        self.target_dump_path,
        "#{self.file_prefix}_#{self.target_schema}.sql"
      )
    end

    def perform!
      dump_schema
      replace_occurrences
      load_schema
    end

    private

    def dump_schema(options={})
      ENV['PGPASSWORD'] = Storey.database_config[:password]
      prepare_schema_dump_directories

      unless Storey.database_config[:host].blank?
        options[:host] ||= Storey.database_config[:host]
      end
      options[:username] ||= Storey.database_config[:username]
      options[:file]     ||= self.source_file
      options[:schema]   ||= self.source_schema

      switches = options.map { |k, v| "--#{k}=#{v}" }
      switches << '--schema-only' if self.structure_only
      switches = switches.join(" ")

      success = system("pg_dump #{switches} #{Storey.database_config[:database]}")
      unless success
        raise StoreyError, "There seems to have been a problem dumping `#{self.source_schema}` to make a copy of it into `#{self.target_schema}`"
      end
    end

    def prepare_schema_dump_directories
      [self.source_dump_path, self.target_dump_path].each do |d|
        FileUtils.mkdir_p(d)
      end
    end

    def load_schema(options={})
      options[:file] ||= self.target_file
      switches = Storey.command_line_switches(options)

      if duplicating_from_default?
        # Since we are copying the source schema and we're after structure only,
        # the dump_schema ended up creating a SQL file without the "CREATE SCHEMA" command
        # thus we have to create it manually
        ::Storey.create_plain_schema self.target_schema
      end

      `psql #{switches}`

      copy_source_schema_migrations

      ENV['PGPASSWORD'] = nil
    end

    def copy_source_schema_migrations
      ::Storey.switch self.target_schema do
        source_schema_migrations.each do |version|
          unless target_schema_migrations.include?(version)
            command = "INSERT INTO schema_migrations (version) VALUES ('#{version}');"
            ActiveRecord::Base.connection.execute command
          end
        end
      end
    end

    def source_schema_migrations
      ::Storey.switch(self.source_schema) do
        ActiveRecord::Migrator.get_all_versions
      end
    end

    def target_schema_migrations
      ::Storey.switch(self.target_schema) do
        ActiveRecord::Migrator.get_all_versions
      end
    end

    def replace_occurrences
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

    def suffixify(schema_name)
      Suffixifier.suffixify schema_name
    end

  end
end
