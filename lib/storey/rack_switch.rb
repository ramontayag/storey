module Storey
  class RackSwitch

    def initialize(app, processor=Storey.configuration.switch_processor)
      @app, @processor = app, processor
    end

    def call(env)
      schema = @processor.call(env)

      if schema
        Storey.switch(schema) { @app.call(env) }
      else
        @app.call(env)
      end
    end

  end
end
