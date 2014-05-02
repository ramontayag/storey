require "spec_helper"

module Storey
  describe SetsEnvPassword, ".with" do

    before do
      ENV["PGPASSWORD"] = "somethingelse"
    end

    it "sets the env password found in the database config" do
      described_class.with("asd")
      expect(ENV["PGPASSWORD"]).to eq "asd"
    end

    context "password is an integer" do
      it "sets the password as a string" do
        described_class.with(1)
        expect(ENV["PGPASSWORD"]).to eq "1"
      end
    end

  end
end
