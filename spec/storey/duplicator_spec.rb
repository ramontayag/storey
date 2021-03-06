require 'spec_helper'

describe Storey::Duplicator do

  describe '#perform!' do
    context "when the dump is a failure" do
      it 'raises an error' do
        duplicator = described_class.new('non-existent-will-fail-dump', 'new')
        expected_msg = [
          "Problem dumping `non-existent-will-fail-dump` to make a copy of it",
          "into `new`: pg_dump: no matching schemas were found",
        ].join(" ")
        expect { duplicator.perform! }.
          to raise_error(Storey::StoreyError).
          with_message(/#{expected_msg}/)
      end
    end

    it 'removes the target and source sql files after work' do
      Storey.create 'boo'
      duplicator = described_class.new('boo', 'ya')
      duplicator.perform!
      source_dump_dir =
        File.join(Rails.root, 'tmp', 'schema_dumps', 'source', '*.*')
      target_dump_dir =
        File.join(Rails.root, 'tmp', 'schema_dumps', 'target', '*.*')
      expect(Dir[source_dump_dir]).to be_empty
      expect(Dir[target_dump_dir]).to be_empty
    end

    it "does not used cached schema migration versions when copying" do
      s1_versions_count = nil
      Storey.create("s1") do
        s1_versions_count = ActiveRecord::SchemaMigration.count
      end

      duplicator = described_class.new('s1', 's2')
      duplicator.perform!

      Storey.switch("s2") do
        expect(ActiveRecord::SchemaMigration.count).to eq s1_versions_count
      end
    end
  end

end
