require 'spec_helper'

describe Storey, "#drop" do
  context "when suffix is set" do
    before do
      Storey.suffix = "bar"
      Storey.create "foo"
    end

    it "should drop the schema with the suffix" do
      Storey.drop "foo"
      Storey.schemas.should_not include("foo")
    end
  end

  context "when suffix is not set" do
    it "should drop the schema without the suffix" do
      Storey.create "foobar"
      Storey.drop "foobar"
      Storey.schemas.should_not include("foobar")
    end
  end

  context "when the schema does not exist" do
    it "should raise an error" do
      expect {
        Storey.drop "foobar"
      }.to raise_error(Storey::SchemaNotFound, %{The schema "foobar" cannot be found.})
    end
  end
end
