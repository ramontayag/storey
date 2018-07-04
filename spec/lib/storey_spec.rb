require 'spec_helper'

RSpec.describe Storey do

  describe ".configure" do
    it "customizes settings" do
      described_class.configure do |c|
        c.database_url = "postgres://url.com/db"
      end

      expect(described_class.configuration.database_url).
        to eq "postgres://url.com/db"
    end
  end

  describe ".switch" do
    it "does not cache between switches" do
      Storey.create("s1") do
        2.times {|n| Post.create(name: n.to_s) }
      end

      Storey.create("s2") do
        3.times {|n| Post.create(name: n.to_s) }
      end

      Storey.switch("s1") { expect(Post.count).to eq 2 }
      Storey.switch("s2") { expect(Post.count).to eq 3 }
    end
  end

end
