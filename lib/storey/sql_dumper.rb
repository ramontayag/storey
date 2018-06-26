module Storey
  class SqlDumper

    easy_class_to_instance

    def initialize(options={})
      @file = options[:file] || File.join(Rails.root, "db", "structure.sql")
    end

    def dump
      stdout_str, stderr_str, status = Open3.capture3(command)
      raise "Error dumping database: #{stderr_str}" if status.exitstatus != 0
    end

    private

    def abcs
      @abcs ||= ::ActiveRecord::Base.configurations.with_indifferent_access[Rails.env]
    end

    def search_path
      @search_path ||= abcs[:schema_search_path]
    end

    def database_name
      @database_name ||= Shellwords.escape(abcs[:database])
    end

    def command
      return @command if defined?(@command)
      args = Storey.database_config.slice(:host, :username, :password).merge(
        structure_only: true,
        file: @file,
        schemas: search_path,
        database: database_name,
      )
      @command = BuildsDumpCommand.execute(args)
    end

  end
end
