require 'spec_helper'

describe 'Storey', '#default_search_path' do

  it 'should include the persistent schemas' do
    Storey.persistent_schemas = %w(hello there)
    Storey.default_search_path.should == '"$user",public,hello,there'
  end

end
