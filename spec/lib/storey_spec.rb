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

end
