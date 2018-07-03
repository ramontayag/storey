module Storey
  class GenDumpCommand

    def self.call(options={})
      switches = {}

      if options[:database_url].nil?
        if options[:database].blank?
          raise ArgumentError, 'database must be supplied'
        end

        switches['host'] = options[:host] if options[:host].present?
        switches['username'] = options[:username] if options[:username].present?
      end

      switches['schema-only'] = nil if options[:structure_only]
      switches['no-privileges'] = nil
      switches['no-owner'] = nil
      switches[:file] = Shellwords.escape(options[:file])

      if options[:schemas]
        schemas = options[:schemas].split(',')
        schemas_switches = schemas.map do |part|
          Utils.command_line_switches_from({schema: Shellwords.escape(part) })
        end
      end

      command_parts = []
      if options[:password].present?
        command_parts << "PGPASSWORD=#{options[:password]}"
      end
      command_parts << "pg_dump"
      command_parts << options[:database_url] if options[:database_url].present?
      command_parts += [
        Utils.command_line_switches_from(switches),
        schemas_switches,
        options[:database],
      ]
      command_parts.compact.join(' ')
    end

  end
end
