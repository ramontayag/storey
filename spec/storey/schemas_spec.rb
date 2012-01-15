require 'spec_helper'

describe Storey, "#schemas" do
  context "when suffix is set" do
    before do
      Storey.suffix = "_roboto"
    end

    it "should return an array of the schemas without the suffix by default" do
      Storey.create "mr"
      Storey.schemas.should include("mr")
    end

    it "should include the public schema by default" do
      Storey.schemas.should include("public")
    end

    it "should not include any postgres schemas" do
      Storey.schemas do |schema|
        schema.should_not include("pg_")
        schema.should_not == "information_schema"
      end
    end

    context "when suffix => true" do
      it "should return an array of the schemas with the suffix" do
        Storey.create "mr"
        Storey.schemas(:suffix => true).should include("mr_roboto")
      end
    end

    context "when suffix => false" do
      it "should return an array of the schemas without the suffix" do
        Storey.create "mr"
        Storey.schemas(:suffix => false).should include("mr")
      end
    end

    context "when :public => true" do
      it "should return an array of the schemas without the public schema" do
        Storey.schemas(:public => true).should include("public")
      end
    end

    context "when :public => false" do
      it "should return an array of the schemas with the public schema" do
        Storey.schemas(:public => false).should_not include("public")
      end
    end
  end
end
