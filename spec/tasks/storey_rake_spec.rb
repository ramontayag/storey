require 'spec_helper'

describe Storey, "rake tasks" do

  before do
    @migration_version_1 = 20120115060713
    @migration_version_2 = 20120115060728

    @number_of_dbs = rand(3) + 1
    @number_of_dbs.times do |db|
      Storey.create "schema_#{db}"
    end
  end

  describe "storey:migrate" do
    before do
      # We don't care how it's migrated
      ActiveRecord::Migrator.stub(:migrate)
    end

    it "should migrate all schemas including public" do
      # +1 to take into account the public schema
      ActiveRecord::Migrator.should_receive(:migrate).exactly(@number_of_dbs + 1).times
      @rake["storey:migrate"].invoke
    end

    context 'when a version is given' do
      it 'should migrate to the given version' do
        ENV['VERSION'] = '3299329'
        ActiveRecord::Migrator.should_receive(:migrate).
          with(ActiveRecord::Migrator.migrations_path, 3299329).
          exactly(@number_of_dbs + 1).times
        @rake["storey:migrate"].invoke
      end
    end
  end

  describe "storey:migrate:up" do
    context "without a version" do
      before do
        ENV['VERSION'] = nil
      end

      it "requires a version to migrate to" do
        expect { @rake['storey:migrate:up'].invoke }.to raise_error("VERSION is required")
      end
    end

    context "with version" do
      before do
        ENV['VERSION'] = @migration_version_2.to_s
      end

      it "migrates up to a specific version" do
        # +1 to take into account the public schema
        Storey::Migrator.should_receive(:run).with(
          :up,
          anything,
          @migration_version_2.to_i
        ).exactly(@number_of_dbs+1).times

        @rake['storey:migrate:up'].invoke
      end
    end
  end

  describe "storey:migrate:down" do
    context "without a version" do
      before do
        ENV['VERSION'] = nil
      end

      it "requires a version to migrate to" do
        expect { @rake['storey:migrate:down'].invoke }.
          to raise_error(RuntimeError, /VERSION is required/)
      end
    end

    context "with version" do
      before do
        ENV['VERSION'] = @migration_version_1.to_s
      end

      it "migrates up to a specific version" do
        Storey::Migrator.should_receive(:run).with(
          :down,
          anything,
          @migration_version_1
        ).exactly(@number_of_dbs+1).times

        @rake['storey:migrate:down'].invoke
      end
    end
  end

  describe "storey:rollback" do
    it "should rollback dbs" do
      Storey::Migrator.should_receive(:rollback_all).once
      @rake['storey:rollback'].invoke
    end

    it "should rollback dbs STEP amt" do
      step = 2
      Storey::Migrator.should_receive(:rollback_all).with(step).once
      ENV['STEP'] = step.to_s
      @rake['storey:rollback'].invoke
    end
  end

end
