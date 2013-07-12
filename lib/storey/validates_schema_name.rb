module Storey
  class ValidatesSchemaName
    RESERVED_SCHEMAS = %w(hstore)

    easy_class_to_instance

    def initialize(name)
      @name = if @name.respond_to?(:to_s)
                name.to_s
              else
                name
              end
    end

    def valid?
      (@name =~ /^[^0-9][\w]*$/ || @name == '"$user"') &&
        @name !~ /^pg_/ &&
        !RESERVED_SCHEMAS.include?(@name)
    end

    def execute!
      schema_name = self.class.new(@name)
      unless schema_name.valid?
        if RESERVED_SCHEMAS.include?(@name)
          raise ArgumentError, "`#{@name}` is a reserved schema name"
        end
        raise ArgumentError, "`#{@name}` is not a valid schema name"
      end
    end

  end
end
