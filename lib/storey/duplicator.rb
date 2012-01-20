class Storey::Duplicator
  DUMP_PATH        = File.join Rails.root, 'tmp', 'schema_dumps'
  SOURCE_DUMP_PATH = File.join DUMP_PATH, 'source'
  TARGET_DUMP_PATH = File.join DUMP_PATH, 'target'

  attr_accessor :source_schema, :target_schema, :source_file, :target_file

  def initialize(from_schema, to_schema)
    self.source_schema = Storey.suffixify from_schema
    self.target_schema = Storey.suffixify to_schema
    self.source_file   = File.join SOURCE_DUMP_PATH, "#{Time.now.to_i}_#{self.source_schema}.sql"
    self.target_file   = File.join TARGET_DUMP_PATH, "#{Time.now.to_i}_#{self.target_schema}.sql"
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

    switches = options.map { |k, v| "--#{k}=#{v}" }.join(" ")

    `pg_dump #{switches} #{Storey.database_config[:database]}`
  end

  def prepare_schema_dump_directories
    [SOURCE_DUMP_PATH, TARGET_DUMP_PATH].each { |d| FileUtils.mkdir_p(d) }
  end

  def load_schema(options={})
    options[:host]     ||= Storey.database_config[:host] unless Storey.database_config[:host].blank?
    options[:dbname]   ||= Storey.database_config[:database]
    options[:username] ||= Storey.database_config[:username]
    options[:file] ||= self.target_file

    switches = options.map { |k, v| "--#{k}=#{v}" }.join(" ")

    `psql #{switches}`
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
end
