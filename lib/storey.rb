require "storey/version"
require "rails/all"
require "active_support/core_ext/module" # so we can use mattr_accessor
require 'storey/active_record/descendants'
require 'storey/railtie' if defined?(Rails)
require 'storey/exceptions'
require 'storey/migrator'
require 'storey/duplicator'
require 'storey/hstore'
require 'storey/dumper'
require 'storey/ruby_dumper'
require 'storey/sql_dumper'
require 'storey/native_schema_matcher'
require 'storey/suffixifier'
require 'storey/unsuffixifier'

module Storey
  RESERVED_SCHEMAS = %w(hstore)

  mattr_accessor :suffix, :persistent_schemas
  mattr_writer :default_search_path
  mattr_reader :excluded_models
  extend self

  def init
    self.default_search_path = self.schema
    self.excluded_models ||= []
    self.persistent_schemas ||= []
    process_excluded_models
  end

  def default_search_path
    default_search_paths = @@default_search_path.split(',')
    paths = default_search_paths + self.persistent_schemas
    paths.uniq!
    paths.compact!
    paths.join(',')
  end

  def default_schema?
    self.schema == self.default_search_path
  end

  def excluded_models=(array)
    @@excluded_models = array
    process_excluded_models
  end

  def schema(options={})
    options[:suffix] ||= false

    name = ::ActiveRecord::Base.connection.schema_search_path

    if options[:suffix]
      name
    else
      unsuffixify name
    end
  end

  def create(name, options={}, &block)
    if name.blank?
      fail ArgumentError, "Must pass in a valid schema name"
    end

    if RESERVED_SCHEMAS.include?(name) && !options[:force]
      fail ArgumentError, "'#{name}' is a reserved schema name"
    end

    if self.schemas.include?(name)
      fail(Storey::SchemaExists,
           %{The schema "#{name}" already exists.})
    end

    if options[:load_database_structure].nil?
      options[:load_database_structure] = true
    end

    if options[:load_database_structure]
      duplicator = Storey::Duplicator.new('public',
                                          name,
                                          structure_only: true)
      duplicator.perform!
      name = suffixify name
      switch name do
        block.call if block_given?
      end
    else
      self.create_plain_schema name
    end
  end

  def create_plain_schema(schema_name)
    name = suffixify schema_name
    command = %{"CREATE SCHEMA #{name}"}
    switches = self.command_line_switches(command: command)
    `psql #{switches}`
  end

  def command_line_switches(options={})
    switches = {}
    if self.database_config.has_key?(:host)
      switches[:host] = self.database_config[:host]
    end
    switches[:dbname] = self.database_config[:database]
    switches[:username] = self.database_config[:username]
    switches = switches.merge(options)
    switches.map {|k, v| "--#{k}=#{v}"}.join(' ')
  end

  def schemas(options={})
    options[:suffix] ||= false
    options[:public] = true unless options.has_key?(:public)

    sql = "SELECT nspname FROM pg_namespace"
    sql << " WHERE nspname !~ '^pg_.*'"
    sql << " AND nspname != 'information_schema'"
    sql << " AND nspname != 'public'" unless options[:public]

    names = ::ActiveRecord::Base.connection.query(sql).flatten

    if options[:suffix]
      names
    else
      names = names.map {|name| unsuffixify(name)}
    end
  end

  def drop(name)
    name = suffixify name
    command = "DROP SCHEMA #{name} CASCADE"
    ::ActiveRecord::Base.connection.execute(command)
  rescue ::ActiveRecord::StatementInvalid => e
    raise(Storey::SchemaNotFound,
          %{The schema "#{name}" cannot be found. Error: #{e}})
  end

  def switch(name=nil, &block)
    if block_given?
      original_schema = schema
      switch name
      result = block.call
      switch original_schema
      result
    else
      reset and return if name.blank? || name == 'public'
      path = self.schema_search_path_for(name)

      unless self.schema_exists?(name)
        fail(Storey::SchemaNotFound, %{The schema "#{path}" cannot be found.})
      end

      ::ActiveRecord::Base.connection.schema_search_path = path
      reset_column_information
    end
  rescue ::ActiveRecord::StatementInvalid => e
    if e.to_s =~ /relation ".*" does not exist at character \d+/
      warn "See https://github.com/ramontayag/storey/issues/11"
      raise e
    else
      raise e
    end
  end

  def schema_exists?(name)
    schema_name = suffixify(name)

    schemas_in_db = self.schemas(suffix: self.suffix.present?)
    schemas_in_db << %("$user")
    schema_names = schema_name.split(',')
    schemas_not_in_db = schema_names - schemas_in_db
    schemas_not_in_db.empty?
  end

  def schema_search_path_for(schema_name)
    schema_names = schema_name.split(',')
    path = [suffixify(schema_name)]
    self.persistent_schemas.each do |schema|
      unless schema_names.include?(schema)
        path << suffixify(schema)
      end
    end
    path.uniq.join(',')
  end

  def reload_config!
    self.excluded_models = []
    self.persistent_schemas = []
    self.suffix = nil
  end

  def database_config
    Rails.configuration.
      database_configuration[Rails.env].
      with_indifferent_access
  end

  def duplicate!(from_schema, to_schema, options={})
    duplicator = Duplicator.new(from_schema, to_schema, options)
    duplicator.perform!
  end

  def matches_default_search_path?(schema_name)
    paths = self.default_search_path.split(',')
    paths.each do |path|
      return true if path == schema_name
    end
    self.default_search_path == schema_name
  end

  protected

  def schema_migrations
    ::ActiveRecord::Migrator.get_all_versions
  end

  def reset
    path = self.schema_search_path_for(self.default_search_path)
    ::ActiveRecord::Base.connection.schema_search_path = path
  end

  def process_excluded_models
    self.excluded_models.each do |model_name|
      model_name.constantize.tap do |klass|
        table_name = klass.table_name.split('.', 2).last
        klass.table_name = "public.#{table_name}"
      end
    end
  end

  private

  def matches_native_schemas?(schema_name)
    NativeSchemaMatcher.matches?(schema_name)
  end

  def suffixify(schema_name)
    Suffixifier.suffixify(schema_name)
  end

  def unsuffixify(schema_name)
    Unsuffixifier.unsuffixify schema_name
  end

  def reset_column_information
    ::ActiveRecord::Base.descendants.each do |descendant|
      descendant.reset_column_information
    end
  end

end
