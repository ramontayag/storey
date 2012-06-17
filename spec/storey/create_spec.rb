require 'spec_helper'

describe Storey, "#create" do
  it "should load the database structure into the new schema" do
    public_tables = Storey.switch { ActiveRecord::Base.connection.tables }.sort
    Storey.create "foobar" do
      foobar_tables = ActiveRecord::Base.connection.tables.sort
      foobar_tables.should == public_tables
    end
  end

  it "should copy the schema_migrations over" do
    Storey.create "foobar"
    public_schema_migrations = Storey.switch { ActiveRecord::Migrator.get_all_versions }
    Storey.switch "foobar" do
      ActiveRecord::Migrator.get_all_versions.should == public_schema_migrations
    end
  end

  context "when load_database_schema: false" do
    it "should not load the structure" do
      Storey.create "foobar", load_database_structure: false do
        tables = ActiveRecord::Base.connection.tables
        tables.should_not include('companies')
        tables.should_not include('posts')
      end
    end
  end

  context "when no string is passed" do
    it "should raise argument error" do
      expect {Storey.create}.to raise_error(ArgumentError)
    end
  end

  context "when a blank string is passed" do
    it "should raise an argument error about an invalid schema name" do
      expect {Storey.create ""}.to raise_error(ArgumentError, "Must pass in a valid schema name")
    end
  end

  context "when suffix is set" do
    before do
      Storey.suffix = "_rock"
    end

    it "should create a schema with the suffix" do
      Storey.create "foobar"
      Storey.schemas(:suffix => true).should include("foobar_rock")
    end
  end

  context "when suffix is not set" do
    it "should create a schema without a suffix" do
      Storey.create "foobar"
      Storey.schemas.should include("foobar")
    end
  end

  context "when the schema already exists" do
    it "should raise an error" do
      Storey.create "foobar"
      expect {
        Storey.create "foobar"
      }.to raise_error(Storey::SchemaExists, %{The schema "foobar" already exists.})
    end
  end

  context "when a block is passed" do
    it "should create the schema and execute that block in the newly created schema's context" do
      Storey.create "foo" do
        Post.create :name => "Hello"
      end

      Post.count.should be_zero

      Storey.switch "foo" do
        Post.count.should == 1
      end
    end

    context "when creating a record in a table that doesn't exist" do
      it "should re-raise the original error" do
        Storey.create "foo" do
          expect {Fake.create}.to raise_error(ActiveRecord::StatementInvalid)
        end
      end
    end
  end

  context 'when creating a reserved schema' do
    it 'should fail' do
      expect {Storey.create('hstore')}.to raise_error(ArgumentError, "'hstore' is a reserved schema name")
    end

    context 'when force: true is passed in' do
      it 'should create the schema' do
        expect {
          Storey.create 'hstore', force: true
        }.to_not raise_error(ArgumentError)
        Storey.schemas.should include('hstore')
      end
    end
  end

end
