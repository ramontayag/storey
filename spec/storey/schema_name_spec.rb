require 'spec_helper'

describe Storey::SchemaName do

  it 'should behave just like a string' do
    expect(described_class.new('hi')).to eq('hi')
  end

  describe '#valid?' do
    subject { described_class.new(schema_name) }

    context 'when the name starts with `pg_`' do
      let(:schema_name) { 'pg_shouldbereserved' }
      it { should_not be_valid }
    end

    context 'when the name starts with a number' do
      let(:schema_name) { '8isthemagicnumber' }
      it { should_not be_valid }
    end

    context 'when the name has a space' do
      let(:schema_name) { 'almost valid' }
      it { should_not be_valid }
    end

    context 'when the name is valid' do
      let(:schema_name) { 'a_5' }
      it { should be_valid }
    end

    context 'when the name is valid with $ and "' do
      let(:schema_name) { '"$user"' }
      it { should be_valid }
    end

    context 'when the string is blank' do
      let(:schema_name) { '' }
      it { should_not be_valid }
    end

    context 'when the string is nil' do
      let(:schema_name) { nil }
      it { should_not be_valid }
    end
  end

  describe '#reserved?' do
    subject { described_class.new(schema_name) }

    context 'when the schema name is reserved' do
      let(:schema_name) { described_class::RESERVED_SCHEMAS.sample }
      it { should be_reserved }
    end

    context 'when the schema name is not reserved' do
      let(:schema_name) { 'available' }
      it { should_not be_reserved }
    end
  end

  describe '#validate_format!' do
    subject { described_class.validate_format!(schema_name) }

    context 'an invalid name is given' do
      let(:schema_name) { 'a a' }
      it 'should fail' do
        expect { subject }.
          to raise_error(Storey::SchemaInvalid, '`a a` is not a valid schema name')
      end
    end

    context 'a valid name is given' do
      let(:schema_name) { 'a_5' }
      it 'should initialize without exceptions' do
        expect { subject }.to_not raise_error
      end
    end
  end

  describe '#validate_reserved!' do
    context 'when the name is a reserved schema name' do
      let(:schema_name) { described_class::RESERVED_SCHEMAS.sample }

      it 'should fail with reserved schema argument error' do
        expect { described_class.validate_reserved!(schema_name) }.
          to raise_error(Storey::SchemaReserved, "`#{schema_name}` is a reserved schema name")
      end
    end
  end

end
