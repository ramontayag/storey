require 'spec_helper'

describe Storey, "#duplicate!" do
  before do
    # Always clear the tmp file of the Rails app
    FileUtils.rm_rf(Storey::Duplicator::DUMP_PATH)
  end

  context "when there's no suffix set" do
    before do
      Storey.create 'ricky' do
        Post.create :name => "Hi"
      end
    end

    it "should create a schema with the same data under a new name" do
      Storey.duplicate! 'ricky', 'bobby'
      Storey.schemas.should include('bobby')
      Storey.switch 'bobby' do
        Post.count.should == 1
        Post.find_by_name("Hi").should_not be_nil
      end
    end
  end

  it "should clear the PGPASSWORD environment variable" do
    Storey.create 'ricky'
    Storey.duplicate! 'ricky', 'bobby'
    ENV['PGPASSWORD'].should be_blank
  end

  context "when a suffix is set" do
    before do
      Storey.suffix = "_shakenbake"
      Storey.create 'ricky' do
        Post.create :name => "Hi"
      end
    end

    it "should create a schema with the suffix" do
      Storey.duplicate! "ricky", "bobby"
      Storey.schemas(:suffix => true).should include("bobby_shakenbake")
      Storey.switch 'bobby' do
        Post.count.should == 1
        Post.find_by_name("Hi").should_not be_nil
      end
    end
  end
end
