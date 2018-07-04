require 'spec_helper'

describe Storey, '#schema_search_path_for' do

  context 'given a search path that is one of the persistent schemas' do
    Storey.configuration.persistent_schemas = %w(halla)
    Storey.schema_search_path_for('bola,halla').should == 'bola, halla'
    Storey.schema_search_path_for('halla').should == 'halla'
    Storey.schema_search_path_for('halla,bola').should == 'halla, bola'
  end

end
