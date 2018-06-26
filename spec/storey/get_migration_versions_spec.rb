require 'spec_helper'

module Storey
  RSpec.describe GetMigrationVersions do

    before do
      Storey.create("schema_1") do
        ActiveRecord::SchemaMigration.create!(version: 123)
      end

      Storey.create("schema_2") do
        ActiveRecord::SchemaMigration.create!(version: 200)
        ActiveRecord::SchemaMigration.create!(version: 201)
      end

      Storey.create("schema_3") do
        ActiveRecord::SchemaMigration.create!(version: 300)
        ActiveRecord::SchemaMigration.create!(version: 301)
        ActiveRecord::SchemaMigration.create!(version: 302)
      end
    end

    context "given a schema" do
      it "returns the migration versions in that schema and switches back the schema" do
        expect(described_class.("schema_1")).to include(123)
        expect(Storey).to be_default_schema
        expect(described_class.("schema_3")).to include(300, 301, 302)
        expect(Storey).to be_default_schema
      end
    end

    context "without a schema" do
      it "returns the migration version in the current schema" do
        Storey.switch "schema_1"
        expect(described_class.()).to include(123)
        Storey.switch "schema_2"
        expect(described_class.()).to include(200, 201)
      end
    end

  end
end
