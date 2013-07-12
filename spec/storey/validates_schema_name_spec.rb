require 'spec_helper'

describe Storey::ValidatesSchemaName do

  describe '#execute' do
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

    context 'a reserved schema name was given' do
      let(:schema_name) { described_class::RESERVED_SCHEMAS.sample }
      it { should_not be_valid }
    end
  end

  describe '.validate!' do
    context 'an invalid name is given' do
      it 'should fail' do
        expect { described_class.execute!('a a') }.
          to raise_error(ArgumentError, '`a a` is not a valid schema name')
      end
    end

    context 'when the name is a reserved schema name' do
      let(:schema_name) { described_class::RESERVED_SCHEMAS.sample }

      it 'should fail with reserved schema argument error' do
        expect { described_class.execute!(schema_name) }.
          to raise_error(ArgumentError, "`#{schema_name}` is a reserved schema name")
      end
    end

    context 'a valid name is given' do
      it 'should initialize without exceptions' do
        expect { described_class.execute!('a_5') }.to_not raise_error
      end
    end
  end

end
