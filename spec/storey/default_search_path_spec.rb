require 'spec_helper'

describe 'Storey', '#default_search_path' do

  context "when #default_search_path has not been set before" do
    it "defaults to the current schema" do
      expect(Storey.default_search_path).to eq '"$user",public'
    end
  end

  it 'includes the persistent schemas' do
    Storey.persistent_schemas = %w(hello there)
    expect(Storey.default_search_path).to eq '"$user",public,hello,there'
  end

  context 'when the persistent schemas includes `public`' do
    it 'has one instance of public' do
      Storey.persistent_schemas = %w(public hello)
      expect(Storey.default_search_path).to eq '"$user",public,hello'
    end
  end

end
