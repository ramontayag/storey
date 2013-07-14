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

    def validate_format!
      unless self.valid?
        raise SchemaInvalid, "`#{@name}` is not a valid schema name"
      end
    end

    def validate_reserved!
      if self.reserved?
        raise SchemaReserved, "`#{@name}` is a reserved schema name"
      end
    end

  end
end
