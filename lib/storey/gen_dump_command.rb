module Storey
  class GenDumpCommand

    def self.call(
      database_url: Storey.configuration.database_url,
      database: nil,
      host: nil,
      username: nil,
      structure_only: false,
      file: nil,
      schemas: nil,
      password: nil
    )
      switches = {}

      if database_url.nil?
        if database.blank?
          raise ArgumentError, 'database must be supplied'
        end

        switches['host'] = host if host.present?
        switches['username'] = username if username.present?
      end

      switches['schema-only'] = nil if structure_only
      switches['no-privileges'] = nil
      switches['no-owner'] = nil
      switches[:file] = Shellwords.escape(file)

      if schemas
        schemas = schemas.split(',')
        schemas_switches = schemas.map do |part|
          Utils.command_line_switches_from({schema: Shellwords.escape(part) })
        end
      end

      command_parts = []
      if password.present?
        command_parts << "PGPASSWORD=#{password}"
      end
      command_parts << "pg_dump"
      command_parts << database_url if database_url.present?
      command_parts += [
        Utils.command_line_switches_from(switches),
        schemas_switches,
        database,
      ]
      command_parts.compact.join(' ')
    end

  end
end
