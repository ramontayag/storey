module Storey
  class Unsuffixifier

    def self.unsuffixify(*args)
      self.new(*args).unsuffixify
    end

    def initialize(schema_name)
      @schema_name = schema_name
    end

    def unsuffixify
      schema_names.map do |schema_name|
        if schema_name =~ /(["\$\w]+)#{suffix}/
          $1
        else
          schema_name
        end
      end.join(',')
    end

    private

    def suffix
      Storey.configuration.suffix
    end

    def schema_names
      @schema_name.split(',')
    end

  end
end
