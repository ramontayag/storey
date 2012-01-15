# Storey

Storey is used to manage multiple schemas in your multi-tenant Rails application.

Heavily inspired by the Apartment gem, Storey simplifies the implementation of managing a multi-tenant application. This simplifies things by doing away with the other implementations that Apartment has - like MysqlAdapter and managing multiple databases (instead of managing multiple schemas) which complicated development and testing.

# Configuration

Typically set in an initializer: config/initializer/storey.rb

    # Defines the tables that should stay available to all (ie in the public schema)
    Storey.excluded_tables = %w(users companies)

    # If set, all schemas are created with the suffix.
    # Used for obscuring the schema name - which is important when performing schema duplication.
    # Storey.suffix = "_suffix"

# Methods

## schemas

Returns all schemas except postgres' schemas.

Accepts options:

    :exclude_public => true

Usage:

    Storey.schemas
    Storey.schemas(:exclude_public => true)

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

Copies a schema with all data under a new name.

Usage:

    Storey.duplicate!("original_schema", "new_schema")
