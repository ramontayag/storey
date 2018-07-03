require 'spec_helper'

module Storey
  describe GenLoadCommand do

    let(:options) do
      {
        file: '/path/file dump.sql',
        database: 'mydb',
        username: 'myuser',
        host: 'localhost',
        port: '5467',
        password: '12345',
        database_url: nil,
      }
    end

    subject(:command) { described_class.(options) }

    it { should include('--file=/path/file\ dump.sql') }
    it { should include('--dbname=mydb') }
    it { should include('--username=myuser') }
    it { should include('--host=localhost') }
    it { should include('--password=12345')}

    context "when database_url is passed in" do
      subject(:command) do
        described_class.(
          database_url: "postgres://u:p@host:5432/db",
          file: '/path/file dump.sql',
          host: 'localhost',
        )
      end

      it "prioritizes the database_url" do
        expect(command).to include "psql postgres://u:p@host:5432/db"
        expect(command).to_not include "localhost"
      end
    end

    context "when database_url is set in Storey config" do
      before do
        Storey.configuration.database_url = "postgres://u:p@host:5432/db"
      end

      subject(:command) do
        described_class.(file: '/path/file dump.sql', host: 'localhost')
      end

      it "prioritizes the database_url" do
        expect(command).to include "psql postgres://u:p@host:5432/db"
        expect(command).to_not include "localhost"
      end
    end

    context 'when host is not set' do
      before { options[:host] = nil }
      it { should_not include('--host=') }
    end

    context 'when username is not set' do
      before { options[:username] = nil }
      it { should_not include('--username') }
    end

    context 'when no password is given' do
      before { options[:password] = nil }
      it { should_not include('--password') }
      it { should include('--no-password') }
    end

    context 'when no file is given' do
      before { options[:file] = nil }
      it { should_not include('--file=')}
    end

    context 'command is given' do
      before { options[:command] = "EXECUTE THIS!" }
      it { should include('--command="EXECUTE THIS!"')}
    end

    it 'should generate a valid command' do
      expect(subject).to eq('psql --file=/path/file\ dump.sql --dbname=mydb --username=myuser --host=localhost --port=5467 --password=12345')
    end
  end

end
