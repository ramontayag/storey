require 'spec_helper'

describe Storey, '#schema_exists?' do
  context 'the schema is the default search path' do
    it 'should return true' do
      expect(Storey.schema_exists?('"$user",public')).to be true
    end
  end

  context 'when there is no suffix' do
    context 'when the schema exists' do
      before do
        Storey.create 'hoo'
      end

      it 'should return true' do
        expect(Storey.schema_exists?('hoo')).to be true
      end
    end

    context 'when the schema does not exist' do
      it 'should return false' do
        expect(Storey.schema_exists?('boo')).to be false
      end
    end
  end

  context 'when there is a suffix' do
    context 'when the schema exists' do
      before do
        Storey.suffix = '_boo'
        Storey.create 'croo'
      end

      it 'should return true' do
        expect(Storey.schema_exists?('croo')).to be true
      end
    end

    context 'when the schema does not exist' do
      it 'should return false' do
        expect(Storey.schema_exists?('croo')).to be false
      end
    end
  end
end
