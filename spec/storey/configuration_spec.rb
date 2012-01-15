require 'spec_helper'

describe Storey, "configuration" do
  it "should allow setting of suffix" do
    Storey.suffix = "_hello"
    Storey.suffix.should == "_hello"
  end

  it "should allow setting of excluded_models" do
    Storey.excluded_models = %w(Company)
    Storey.excluded_models.should == %w(Company)
  end
end
