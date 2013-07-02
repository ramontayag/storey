module Storey
  class SqlDumper

    easy_class_to_instance

    def initialize(options={})
      @file = options[:file] || File.join(Rails.root, "db", "structure.sql")
    end

    def dump
      abcs = ::ActiveRecord::Base.configurations
      set_psql_env(abcs[Rails.env])
      search_path = abcs[Rails.env]['schema_search_path']
      unless search_path.blank?
        search_path = search_path.split(",").map do |search_path_part|
          "--schema=#{Shellwords.escape(search_path_part.strip)}"
        end
        search_path.join(" ")
      end

      db_config = Shellwords.escape(abcs[Rails.env]['database'])
      `pg_dump -i -s -x -O -f #{Shellwords.escape(@file)} #{search_path} #{db_config}`

      raise 'Error dumping database' if $?.exitstatus == 1

      File.open(@file, "a") do |f|
        search_path = ::ActiveRecord::Base.connection.schema_search_path
        f << "SET search_path TO #{search_path};\n\n"
      end
    end

  end
end
