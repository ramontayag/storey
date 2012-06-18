require 'spec_helper'

describe Storey, '.schema_search_path_for' do
  context 'given a blank argument' do
    it 'should return the default path' do
      Storey.switch
      Storey.schema.should == Storey.default_search_path
    end
  end
end
