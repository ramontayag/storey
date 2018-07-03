module Storey
  class Duplicator

    def initialize(from_schema, to_schema, options={})
      unless from_schema
        fail SchemaNotFound, "cannot duplicate from nil schema"
      end

      @dump_dir = File.join(Rails.root, 'tmp', 'schema_dumps')
      @source_dump_dir = File.join(@dump_dir, 'source')
      @target_dump_dir = File.join(@dump_dir, 'target')
      @structure_only = options[:structure_only] || false

      @source_schema = suffixify(from_schema)
      @target_schema = suffixify(to_schema)
      @file_prefix = "#{Time.now.to_i}_#{rand(100000)}"
      @source_file = File.join(@source_dump_dir,
                               "#{@file_prefix}_#{@source_schema}.sql")
      @target_file = File.join(@target_dump_dir,
                               "#{@file_prefix}_#{@target_schema}.sql")
    end

    def perform!
      dump_schema
      replace_occurrences
      load_schema
      clean_source
      clean_target
    end

    private

    def clean_source
      FileUtils.rm(@source_file)
    end

    def clean_target
      FileUtils.rm(@target_file)
    end

    def dump_schema(options={})
      prepare_schema_dump_directories

      options[:host] ||= Storey.database_config[:host]
      options[:structure_only] = true if @structure_only
      options[:schemas] = @source_schema
      options[:database] ||= Storey.database_config[:database]
      options[:username] ||= Storey.database_config[:username]
      options[:file] = @source_file
      pg_dump_command = GenDumpCommand.(options)

      stdout_str, stderr_str, status = Open3.capture3(pg_dump_command)
      unless status.exitstatus.zero?
        msg = [
          "Problem dumping",
          "`#{@source_schema}`",
          "to make a copy of it into",
          "`#{@target_schema}`:",
          stderr_str,
        ].join(" ")
        raise StoreyError, msg
      end
    end

    def prepare_schema_dump_directories
      [@source_dump_dir, @target_dump_dir].each do |d|
        FileUtils.mkdir_p(d)
      end
    end

    def load_schema(options={})
      options[:file] ||= @target_file
      psql_options = Storey.database_config.merge(options)

      if duplicating_from_default?
        # Since we are copying the source schema and we're after structure only,
        # the dump_schema ended up creating a SQL file without the "CREATE SCHEMA" command
        # thus we have to create it manually
        ::Storey.create_plain_schema @target_schema
      end

      psql_load_command = GenLoadCommand.(psql_options)
      Open3.capture3(psql_load_command)

      copy_source_schema_migrations

      ENV['PGPASSWORD'] = nil
    end

    def copy_source_schema_migrations
      ::Storey.switch @target_schema do
        source_schema_migrations.each do |version|
          unless target_schema_migrations.include?(version)
            command = "INSERT INTO schema_migrations (version) VALUES ('#{version}');"
            ::ActiveRecord::Base.connection.execute command
          end
        end
      end
    end

    def source_schema_migrations
      GetMigrationVersions.(@source_schema)
    end

    def target_schema_migrations
      GetMigrationVersions.(@target_schema)
    end

    def replace_occurrences
      File.open(@source_file, 'r') do |file|
        file.each_line do |line|
          new_line = line.gsub(/#{@source_schema}/, @target_schema)
          File.open(@target_file, 'a') {|tf| tf.puts new_line}
        end
      end
    end

    def duplicating_from_default?
      ::Storey.matches_default_search_path?(@source_schema) && @structure_only
    end

    def suffixify(schema_name)
      Suffixifier.suffixify schema_name
    end

  end
end
