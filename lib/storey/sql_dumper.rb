module Storey
    class SqlDumper

    def self.dump(*args)
      self.new(*args).dump
    end

    def initialize(options={})
      @file = options[:file] || File.join(Rails.root, "db", "structure.sql")
    end

    def dump
      abcs = ::ActiveRecord::Base.configurations
      set_psql_env(abcs[Rails.env])
      search_path = abcs[Rails.env]['schema_search_path']
      unless search_path.blank?
        search_path = search_path.split(",").map{|search_path_part| "--schema=#{Shellwords.escape(search_path_part.strip)}" }.join(" ")
      end
      `pg_dump -i -s -x -O -f #{Shellwords.escape(@file)} #{search_path} #{Shellwords.escape(abcs[Rails.env]['database'])}`
      raise 'Error dumping database' if $?.exitstatus == 1
      File.open(@file, "a") { |f| f << "SET search_path TO #{::ActiveRecord::Base.connection.schema_search_path};\n\n" }
    end

  end
end
