module Storey
  class GenLoadCommand

    def self.call(
      file: nil,
      command: nil,
      database_url: Storey.configuration.database_url,
      database: nil,
      username: nil,
      host: nil,
      port: nil,
      password: nil
    )
      switches = {}
      if file.present?
        switches[:file] = Shellwords.escape(file)
      end
      switches[:command] = %Q("#{command}") if command.present?

      command_parts = ["psql"]

      if database_url.present?
        command_parts << database_url
      else
        switches[:dbname] = database
        switches[:username] = username if username.present?
        switches[:host] = host if host.present?
        switches[:port] = port if port.present?
        if password.present?
          switches[:password] = password
        else
          switches['no-password'] = nil
        end
      end

      command_parts << Utils.command_line_switches_from(switches)
      command_parts.join(' ')
    end

  end
end
