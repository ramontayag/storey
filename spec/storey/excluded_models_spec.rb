require 'spec_helper'

describe Storey, "dealing with excluded_models" do
  before do
    Storey.configuration.excluded_models = %w(Company)
    # In practice, `excluded_models` is not set on the fly, but since we do so
    # in the tests, we must call `init` to set the models to the right tables:
    Storey.init
  end

  it "should always reference these models in the public schema" do
    Storey.create("foo") { Company.create :name => "company_1" }
    Company.create :name => "company_2"

    expect(Company.count).to eq 2
    Storey.switch("foo") { expect(Company.count).to eq 2 }
  end
end
