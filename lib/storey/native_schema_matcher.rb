module Storey
  class NativeSchemaMatcher
    NATIVE_SCHEMAS = ['"$user"', 'public']

    def self.matches?(*args)
      self.new(*args).matches?
    end

    def initialize(schema_name)
      @schema_name = schema_name
    end

    def matches?
      NATIVE_SCHEMAS.include?(@schema_name) ||
        (NATIVE_SCHEMAS - @schema_name.split(',')).empty?
    end

  end
end
