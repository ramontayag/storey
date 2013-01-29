require 'spec_helper'

describe Storey, '#default_schema?' do
  context 'when not in the default schema' do
    it 'should return false' do
      Storey.create 'hah' do
        Storey.default_schema?.should be_false
      end
    end
  end

  context 'when in the default schema' do
    it 'should return true' do
      Storey.switch do
        Storey.default_schema?.should be_true
      end
    end
  end
end
