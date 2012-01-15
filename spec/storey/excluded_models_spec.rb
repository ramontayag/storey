require 'spec_helper'

describe Storey, "dealing with excluded_models" do
  before do
    Storey.excluded_models = %w(Company)
  end

  it "should always reference these models in the public schema" do
    Storey.create("foo") { Company.create :name => "company_1" }
    Company.create :name => "company_2"

    Company.count.should == 2
    Storey.switch("foo") {Company.count.should == 2}
  end
end
