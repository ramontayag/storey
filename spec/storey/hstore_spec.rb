require 'spec_helper'

describe Storey::Hstore do
  describe '.install' do
    it 'should install the extension into the hstore schema' do
      Storey.persistent_schemas = %w(hstore)
      described_class.install
      expect {
        ActiveRecord::Base.connection.execute "DROP EXTENSION hstore"
      }.to_not raise_error(ActiveRecord::StatementInvalid)
    end

    context 'when hstore is not one of the persistent schemas' do
      it 'should fail with an StoreyError' do
        Storey.persistent_schemas = []
        expect {
          described_class.install
        }.to raise_error(Storey::StoreyError, 'You are attempting to install hstore data type, but the hstore schema (where the data type will be installed) is not one of the persistent schemas. Please add hstore to the list of persistent schemas.')
      end
    end
  end
end
