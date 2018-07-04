[![Build Status](https://travis-ci.org/ramontayag/storey.png?branch=master)](https://travis-ci.org/ramontayag/storey)

# Storey

Storey is used to manage multiple schemas in your multi-tenant Rails application.

Heavily inspired by the Apartment gem, Storey simplifies the implementation of managing a multi-tenant application. This simplifies things by doing away with the other implementations that Apartment has - like MysqlAdapter and managing multiple databases (instead of managing multiple schemas) which complicated development and testing.

# Configuration

Typically set in an initializer: `config/initializer/storey.rb`

```ruby
Storey.configure do |c|
  # Defines the tables that should stay available to all (ie in the public schema)
  # Note that there's currently no way to exclude tables that aren't linked to models
  # If you have any ideas on how to do this I'm open to suggestions
  c.excluded_models = %w(User Company Role Permission)

  # If set, all schemas are created with the suffix.
  # Used for obscuring the schema name - which is important when performing schema duplication.
  # c.suffix = "_suffix"

  # Defines schemas that should always stay in the search path, apart from the one you switched to.
  # c.persistent_schemas = %w(hstore)

  # If you use a connection string, set it here. When nil, it falls back to the configuration in database.yml
  c.database_url = ENV["DATABASE_URL"]
end
```

# Methods

## schema

Return the current schema.

Accepts options

    array: true # return the schemas as an array

Usage:

    Storey.schema # "\"$user\", public"
    Storey.schema(array: true) ["\"$user\"", "public"]

## schemas

Returns all postgres' schemas.

Accepts options:

    :public => true

Usage:

    Storey.schemas # defaults to :public => true
    Storey.schemas(:public => true)

## default_schema?

Returns true if the current schema is the default schema. Returns false otherwise. Useful for running migrations only for the public schema.

Usage:

    Storey.default_schema?

## create

Accepts:

    String - name of schema

Usage:

    Storey.create "schema_name"

## drop

Accepts

    String - name of schema

Usage:

    Storey.drop "schema_name"

## switch

Accepts

    String - optional - schema name
    Block - optional

If a block is passed, Storey will execute the block in the specified schema name. Then, it will switch back to the schema it was previously in.

Usage:

    Storey.switch "some_other_schema"
    Post.create "My new post"
    Storey.switch # switch back to the original schema

    Storey.switch "some_other_schema" do
      Post.create "My new post"
    end

## duplicate!(origin, copy)

Accepts

    origin - name of old schema to copy
    copy - name of new schema

Copies a schema with all data under a new name. Best used in conjunction with `Storey.configuration.suffix` set.

Usage:

    Storey.duplicate!("original_schema", "new_schema")

# Rake tasks

## storey:hstore:install

Run `rake storey:hstore:install` to install hstore extension into the hstore schema. Ensure that 'hstore' is one of the persistent schemas.
