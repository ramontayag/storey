require 'spec_helper'

describe Storey::Utils do

  describe '.command_line_switches_from(hash)' do
    it 'should build command line switches from the hash' do
      hash = {some: 'key',
              pretty: 'cool'}
      expect(described_class.command_line_switches_from(hash)).
        to eq("--some=key --pretty=cool")
    end
  end

  describe '.db_command_line_switches_from(db_config)' do
    subject do
      described_class.db_command_line_switches_from(db_config, extra_config)
    end

    context 'db_config does not have :host' do
      let(:db_config) { {} }
      it { should_not include('--host=') }
    end

    context 'db_config has :host' do
      let(:db_config) { {host: 'localhost'} }
      it { should include('--host=localhost') }
    end

    let(:db_config) do
      {
        database: 'mydb',
        username: 'uname'
      }
    end

    let(:extra_config) do
      {
        extra: 'config',
        'without-arg' => nil
      }
    end

    it 'should set the database' do
      expect(subject).to include('--dbname=mydb')
    end

    it 'should set the username' do
      expect(subject).to include('--username=uname')
    end

    it 'should include extra config' do
      expect(subject).to include('--extra=config')
    end

    it 'should set flag arguments' do
      expect(subject).to match(/--without-arg$/)
    end
  end

end
