require 'spec_helper'

describe Storey::BuildsDumpCommand do

  describe '.execute' do
    subject do
      described_class.execute(options)
    end

    let(:options) do
      {
        structure_only: true,
        file: 'myfile.sql',
        schemas: 'public',
        database: 'mydb'
      }
    end

    context 'when structure_only: true' do
      let(:options) do
        {
          database: 'mydb',
          structure_only: true
        }
      end
      it { should include('--schema-only') }
    end

    context 'when structure_only: false' do
      let(:options) do
        {
          database: 'mydb',
          structure_only: false
        }
      end
      it { should_not include('--schema-only') }
    end

    it { should include('--no-privileges') }
    it { should include('--no-owner') }

    context 'file: is "/path/to/file name.sql"' do
      let(:options) do
        {
          database: 'mydb',
          file: '/path/to/file name.sql'
        }
      end
      it { should include('/path/to/file\ name.sql') }
    end

    context "schemas: 'public'" do
      let(:options) do
        {
          database: 'mydb',
          schemas: %q(public)
        }
      end
      it { should include('--schema=public') }
    end

    context "schemas: '$user','public'" do
      let(:options) do
        {
          database: 'mydb',
          schemas: %q($user,public)
        }
      end
      it { should include('--schema=\$user --schema=public') }
    end

    it { should match(/mydb$/)}

    context 'no database is given' do
      let(:options) { {} }
      it 'should fail' do
        expect{subject}.to raise_error(ArgumentError, 'database must be supplied')
      end
    end

    it 'should build a valid full executable command' do
      expect(subject).
        to eq("pg_dump --schema-only --no-privileges --no-owner --file=myfile.sql --schema=public mydb")
    end
  end

end
