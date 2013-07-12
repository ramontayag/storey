module Storey
  class SchemaName < String
    RESERVED_SCHEMAS = %w(hstore)

    easy_class_to_instance

    def initialize(name)
      @name = if @name.respond_to?(:to_s)
                name.to_s
              else
                name
              end
      super @name
    end

    def valid?
      (@name =~ /^[^0-9][\w]*$/ || @name == '"$user"') &&
        @name !~ /^pg_/
    end

    def reserved?
      RESERVED_SCHEMAS.include?(@name)
    end

    def validate!
      schema_name = self.class.new(@name)
      unless schema_name.valid?
        raise ArgumentError, "`#{@name}` is not a valid schema name"
      end
      if schema_name.reserved?
        raise ArgumentError, "`#{@name}` is a reserved schema name"
      end
    end

  end
end
