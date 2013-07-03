module Storey
  class BuildsDumpCommand

    easy_class_to_instance

    def initialize(options={})
      @options = options
      if @options[:database].blank?
        raise ArgumentError, 'database must be supplied'
      end
    end

    def execute

      switches = {}
      switches['schema-only'] = nil if @options[:structure_only]
      switches['no-privileges'] = nil
      switches['no-owner'] = nil
      switches[:file] = Shellwords.escape(@options[:file])

      if @options[:schemas]
        schemas = @options[:schemas].split(',')
        schemas_switches = schemas.map do |part|
          Utils.command_line_switches_from({schema: Shellwords.escape(part) })
        end
      end

      command_parts = ['pg_dump',
                       Utils.command_line_switches_from(switches),
                       schemas_switches,
                       @options[:database]]
      command_parts.compact.join(' ')
    end

  end
end
