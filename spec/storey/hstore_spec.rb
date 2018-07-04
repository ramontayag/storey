require 'spec_helper'

describe Storey::Hstore do
  describe '.install' do
    it 'installs the extension into the hstore schema' do
      Storey.configuration.persistent_schemas = %w(hstore)
      described_class.install
      expect { ::ActiveRecord::Base.connection.execute "DROP EXTENSION hstore" }.
        to_not raise_error
    end

    context 'hstore is not one of the persistent schemas' do
      it 'fails with an StoreyError' do
        Storey.configuration.persistent_schemas = []
        message = 'You are attempting to install hstore data type, but the hstore schema (where the data type will be installed) is not one of the persistent schemas. Please add hstore to the list of persistent schemas.'
        expect { described_class.install }.
          to raise_error(Storey::StoreyError, message)
      end
    end
  end
end
