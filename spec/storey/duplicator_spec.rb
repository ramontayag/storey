require 'spec_helper'

describe Storey::Duplicator do

  describe '#perform!' do
    context "when the dump is a failure" do
      it 'should raise an error' do
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

    it 'should remove the target and source sql files after work' do
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
  end

end
