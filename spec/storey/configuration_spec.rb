require 'spec_helper'

describe Storey, "configuration" do
  it "should allow setting of suffix" do
    Storey.configuration.suffix = "_hello"
    expect(Storey.configuration.suffix).to eq "_hello"
  end

  it "should allow setting of excluded_models" do
    Storey.configuration.excluded_models = %w(Company)
    expect(Storey.configuration.excluded_models).to eq %w(Company)
  end
end
