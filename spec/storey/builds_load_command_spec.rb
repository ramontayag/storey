require 'spec_helper'

module Storey
  describe BuildsLoadCommand do

    describe '.execute' do
      let(:options) do
        {
          file: '/path/file dump.sql',
          database: 'mydb',
          username: 'myuser',
          host: 'localhost',
          port: '5467',
          password: '12345'
        }
      end

      subject { described_class.execute(options) }

      it { should include('--file=/path/file\ dump.sql') }
      it { should include('--dbname=mydb') }
      it { should include('--username=myuser') }
      it { should include('--host=localhost') }
      it { should include('--password=12345')}

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
end
