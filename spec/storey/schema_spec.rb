require 'spec_helper'

describe Storey, "#schema" do
  it "should return the current schema" do
    Storey.schema.should == %{"$user",public}
  end

  context "array: true" do
    it "returns it as an array of strings" do
      expect(Storey.schema(array: true)).to eq %w("$user" public)
    end
  end

  context "when a suffix is set" do
    before do
      Storey.suffix = "_rock"
      Storey.create "hello"
      Storey.switch "hello"
    end

    it "should return the schema without the suffix by default" do
      Storey.schema.should == "hello"
    end

    context "when :suffix => true" do
      it "should return the schema with the suffix" do
        Storey.schema(:suffix => true).should include("hello_rock")
      end
    end

    context "when :suffix => false" do
      it "should return the schema without the suffix" do
        Storey.schema(:suffix => false).should include("hello")
      end
    end
  end
end
