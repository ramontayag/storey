require 'spec_helper'

describe Storey, '.create_plain_schema' do
  context 'when there is no suffix set' do
    it 'should create a schema without a suffix' do
      Storey.create_plain_schema 'dun'
      expect(Storey.schemas(suffix: true)).to include('dun')
    end
  end

  context 'when there is a suffix set' do
    before do
      Storey.configuration.suffix = '_lop'
    end

    it 'should create a schema with the suffix' do
      Storey.create_plain_schema 'dun'
      expect(Storey.schemas(suffix: true)).to include('dun_lop')
    end
  end
end
