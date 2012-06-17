require 'spec_helper'

describe Storey, '.create_plain_schema' do
  context 'when there is no suffix set' do
    it 'should create a schema without a suffix' do
      Storey.create_plain_schema 'dun'
      Storey.schemas(suffix: true).should include('dun')
    end
  end

  context 'when there is a suffix set' do
    before do
      Storey.suffix = '_lop'
    end

    it 'should create a schema with the suffix' do
      Storey.create_plain_schema 'dun'
      Storey.schemas(suffix: true).should include('dun_lop')
    end
  end
end
