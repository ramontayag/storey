class Storey::Dumper

  delegate :dump, to: :dumper

  def self.dump(*args)
    self.new(*args).dump
  end

  def initialize(options={})
    @options = options
  end

  def dumper
    dumper_class.new(@options)
  end

  def dumper_class
    schema_format = Rails.configuration.active_record.schema_format || :ruby
    klass = case schema_format
            when :sql; Storey::SqlDumper
            when :ruby; Storey::RubyDumper
            end
  end

end
