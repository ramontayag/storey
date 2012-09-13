require 'spec_helper'

describe Storey, '.command_line_switches' do
  it 'should build default command line switches for calling the psql command' do
    described_class.stub(:database_config).and_return(:host => 'hoop',
                                                      :database => 'db',
                                                      :username => 'jj')
    described_class.command_line_switches.
      should == "--host=hoop --dbname=db --username=jj"
  end

  context 'given options' do
    it 'should add the options to the switches, overriding any default' do
      described_class.stub(:database_config).and_return(:host => 'hoop',
                                                        :database => 'db',
                                                        :username => 'jj')

      described_class.command_line_switches(:a => 'boo', :host => 'loop').
        should == "--host=loop --dbname=db --username=jj --a=boo"
    end
  end
end
