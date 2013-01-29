class Storey::Dumper
  def self.dump(options={})
    schema_format = Rails.configuration.active_record.schema_format || :ruby
    case schema_format
    when :sql  ; self.dump_structure_sql(options)
    when :ruby ; self.dump_schema_rb(options)
    end
  end

  def self.dump_schema_rb(options={})
    require 'active_record/schema_dumper'
    filename = options[:file] || "#{Rails.root}/db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::Base.establish_connection(Rails.env)
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end

  def self.dump_structure_sql(options={})
    abcs = ActiveRecord::Base.configurations
    filename = options[:file] || File.join(Rails.root, "db", "structure.sql")
    set_psql_env(abcs[Rails.env])
    search_path = abcs[Rails.env]['schema_search_path']
    unless search_path.blank?
      search_path = search_path.split(",").map{|search_path_part| "--schema=#{Shellwords.escape(search_path_part.strip)}" }.join(" ")
    end
    `pg_dump -i -s -x -O -f #{Shellwords.escape(filename)} #{search_path} #{Shellwords.escape(abcs[Rails.env]['database'])}`
    raise 'Error dumping database' if $?.exitstatus == 1
    File.open(filename, "a") { |f| f << "SET search_path TO #{ActiveRecord::Base.connection.schema_search_path};\n\n" }
  end

  private

  def self.set_psql_env(config)
    ENV['PGHOST']     = config['host']          if config['host']
    ENV['PGPORT']     = config['port'].to_s     if config['port']
    ENV['PGPASSWORD'] = config['password'].to_s if config['password']
    ENV['PGUSER']     = config['username'].to_s if config['username']
  end
end
