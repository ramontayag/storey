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

    Company.count.should == 2
    Storey.switch("foo") {Company.count.should == 2}
  end
end
