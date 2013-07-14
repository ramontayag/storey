module Storey
  class Dumper

    easy_class_to_instance
    delegate :dump, to: :dumper

    def initialize(options={})
      @options = options
    end

    def dumper
      dumper_class.new(@options)
    end

    def dumper_class
      schema_format = Rails.configuration.active_record.schema_format || :ruby
      class_name = "#{schema_format.to_s.classify}Dumper"
      namespace = self.class.name.deconstantize.constantize
      namespace.const_get class_name
    end

  end
end
