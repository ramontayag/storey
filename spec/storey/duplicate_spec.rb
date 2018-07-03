require 'spec_helper'

describe Storey, "#duplicate!" do
  before do
    # Always clear the tmp file of the Rails app
    tmp_dir = File.join Rails.root, 'tmp'
    FileUtils.rm_rf(tmp_dir)
  end

  context 'when the target schema is nil' do
    it 'should raise an error' do
      expect { Storey.duplicate! nil, 'new' }.
        to raise_error(Storey::SchemaNotFound, "cannot duplicate from nil schema")
    end
  end

  context "when there's no suffix set" do
    before do
      Storey.create 'ricky' do
        Post.create :name => "Hi"
      end
    end

    it "should create a schema with the same data under a new name" do
      Storey.duplicate! 'ricky', 'bobby'
      expect(Storey.schemas).to include('bobby')
      Storey.switch 'bobby' do
        expect(Post.count).to eq(1)
        Post.find_by_name("Hi").should_not be_nil
      end
    end

    context 'when setting structure_only: true' do
      before do
        Storey.duplicate! 'ricky', 'bobby', structure_only: true
      end

      it 'should create a duplicate schema but copy the structure only' do
        expect(Storey.schemas).to include('bobby')
        Storey.switch 'bobby' do
          expect(Post.count).to eq(0)
        end
      end

      it 'should copy all the schema_migrations over' do
        public_schema_migrations = Storey.switch { Storey::GetMigrationVersions.() }
        Storey.switch 'bobby' do
          Storey::GetMigrationVersions.().should == public_schema_migrations
        end
      end
    end

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
