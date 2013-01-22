require 'spec_helper'

describe Storey::Migrator do
  before do
    @original_schema = ActiveRecord::Base.connection.schema_search_path
    @schema_1 = "first_schema"
    Storey.create @schema_1
  end

  describe '.migrate_all' do
    it 'should migrate the default search path first, then all available schemas' do
      described_class.should_receive(:migrate).with('public').ordered
      described_class.should_receive(:migrate).with(@schema_1).ordered
      described_class.migrate_all
    end

    it 'should dump the database' do
      Storey::Dumper.should_receive(:dump)
      described_class.migrate_all
    end
  end

  describe '.migrate' do
    context 'given a schema' do
      it 'should connect to new db, then reset when done' do
        ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@schema_1).once
        ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@original_schema).once
        Storey::Migrator.migrate(@schema_1)
      end

      it "should migrate db" do
        ActiveRecord::Migrator.should_receive(:migrate)
        Storey::Migrator.migrate(@schema_1)
      end
    end
  end

  describe "#run" do
    before do
      @migration_version_1 = 20120115060713
      @migration_version_2 = 20120115060728
    end

    context "up" do
      it "should connect to new db, then reset when done" do
        ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@schema_1).once
        ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@original_schema).once
        Storey::Migrator.run(:up, @schema_1, @migration_version_2)
      end

      it "should migrate to a version" do
        ActiveRecord::Migrator.should_receive(:run).with(:up, anything, @migration_version_1)
        Storey::Migrator.run(:up, @schema_1, @migration_version_1)
      end
    end

    describe "down" do
      it "should connect to new db, then reset when done" do
        ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@schema_1).once
        ActiveRecord::Base.connection.should_receive(:schema_search_path=).with(@original_schema).once
        Storey::Migrator.run(:down, @schema_1, @migration_version_2)
      end

      it "should migrate to a version" do
        ActiveRecord::Migrator.should_receive(:run).with(:down, anything, @migration_version_1)
        Storey::Migrator.run(:down, @schema_1, @migration_version_1)
      end
    end

    describe '.rollback_all' do
      it 'should rollback all schemas exactly :steps times' do
        ['public', 'first_schema'].each do |schema|
          described_class.should_receive(:rollback).
            with(schema, steps).once
        end
        described_class.rollback_all(steps)
      end
    end

    describe "#rollback" do
      it "should rollback the db" do
        @steps = 2
        ActiveRecord::Migrator.should_receive(:rollback).with(anything, @steps)
        Storey::Migrator.rollback(@schema_1, @steps)
      end
    end
  end
end
