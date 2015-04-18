require 'spec_helper'

describe Storey, '#default_schema?' do
  context 'when not in the default schema' do
    it 'return false' do
      Storey.create 'hah' do
        expect(Storey.default_schema?).to be false
      end
    end
  end

  context 'when in the default schema' do
    it 'should return true' do
      Storey.switch do
        expect(Storey.default_schema?).to be true
      end
    end
  end
end
