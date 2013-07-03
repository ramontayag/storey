module Storey
  class Utils

    def self.db_command_line_switches_from(db_config={}, extra_config={})
      switches = {}
      if db_config.has_key?(:host)
        switches[:host] = db_config[:host]
      end
      switches[:dbname] = db_config[:database]
      switches[:username] = db_config[:username]
      command_line_switches_from switches.merge(extra_config)
    end

    def self.command_line_switches_from(hash={})
      hash.map { |k, v| "--#{k}=#{v}" }.join(' ')
    end

  end
end
