require 'spec_helper'

describe 'Storey', '#default_search_path' do

  context "when #default_search_path has not been set before" do
    it "defaults to the current schema" do
      Storey.create "anotherschema"

      # A bit of a hack, but set the @@default_search_path so we can test
      # the scenario when no path has been set
      Storey.class_variable_set("@@default_search_path", nil)

      Storey.switch "anotherschema"

      expect(Storey.default_search_path).to eq '"$user",public'
    end
  end

  it 'includes the persistent schemas' do
    Storey.configuration.persistent_schemas = %w(hello there)
    expect(Storey.default_search_path).to eq '"$user",public,hello,there'
  end

  context 'when the persistent schemas includes `public`' do
    it 'has one instance of public' do
      Storey.configuration.persistent_schemas = %w(public hello)
      expect(Storey.default_search_path).to eq '"$user",public,hello'
    end
  end

end
