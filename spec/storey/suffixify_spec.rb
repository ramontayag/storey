require 'spec_helper'

describe Storey, '.suffixify' do
  context 'given a schema that is not the default schema' do
    it 'should not add a suffix' do
      Storey.suffix = '_doo'
      Storey.suffixify('public').should == 'public'
      Storey.suffixify(%{"$user",public}).should == %{"$user",public}
    end
  end
end
