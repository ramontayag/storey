module Storey
  class Suffixifier

    def self.suffixify(*args)
      self.new(*args).suffixify
    end

    def initialize(schema_name)
      @schema_name = schema_name
    end

    def suffixify
      schema_names.map do |schema_name|
        if schema_name =~ /\w+#{suffix}/ || native_schema?(schema_name)
          schema_name
        else
          "#{schema_name}#{suffix}"
        end
      end.join(', ')
    end

    private

    def schema_names
      @schema_names ||= @schema_name.split(',').map(&:strip)
    end

    def suffix
      Storey.suffix
    end

    def native_schema?(schema_name)
      NativeSchemaMatcher.matches?(schema_name)
    end

  end
end
