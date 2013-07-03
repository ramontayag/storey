module Storey
  class SqlDumper

    easy_class_to_instance

    def initialize(options={})
      @file = options[:file] || File.join(Rails.root, "db", "structure.sql")
    end

    def dump
      `#{command}`
      raise 'Error dumping database' if $?.exitstatus == 1
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
      @command ||= BuildsDumpCommand.execute(structure_only: true,
                                             file: @file,
                                             schemas: search_path,
                                             database: database_name)
    end

  end
end
