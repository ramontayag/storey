require 'spec_helper'

describe Storey, "#switch" do
  it "should return the last execution of code in the block" do
    Storey.create "foo"
    post = Storey.switch "foo" do
      Post.create
    end
    post.should be_kind_of(Post)
  end

  context "with a schema set" do
    before do
      Storey.suffix = "_hello"
      Storey.create "foobar"
    end

    it "should switch to that schema with the suffix appended" do
      Storey.switch "foobar" do
        Storey.schema(:suffix => true).should == "foobar_hello"
      end
    end
  end

  context 'when in a database transaction' do
    it 'should raise an exception' do
      Storey.create 'foobar'
      ActiveRecord::Base.transaction do
        expect {Storey.switch 'foobar'}.
          to raise_error(Storey::WithinTransaction, 'Cannot switch while in a database transaction')
      end
    end
  end

  context "with a schema passed" do
    before do
      Storey.create "foobar"
    end

    context "with a block passed" do
      it "should execute the block in that schema" do
        Storey.switch "foobar" do
          Post.create :name => "hi"
          Post.count.should == 1
        end
        Post.count.should be_zero
      end

      it "should return to the schema that the app was previously in" do
        Storey.create "tintin"
        Storey.switch "foobar"
        Storey.switch "tintin" do; end
        Storey.schema.should == "foobar"
      end
    end

    context "without a block passed" do
      it "should switch the context to the schema specified" do
        Storey.schema.should_not == "foobar"
        Storey.switch "foobar"
        Storey.schema.should == "foobar"
      end
    end
  end

  context "when the schema passed does not exist" do
    context "when the suffix is set" do
      before do
        Storey.suffix = "_rock"
      end

      it "should raise an error naming the schema with suffix" do
        expect {Storey.switch "babo"}.to raise_error(Storey::SchemaNotFound, %{The schema "babo_rock" cannot be found.})
      end
    end

    context "when the suffix is not set" do
      it "should raise an error" do
        expect {Storey.switch "babo"}.to raise_error(Storey::SchemaNotFound, %{The schema "babo" cannot be found.})
      end
    end
  end

  context "with no schema passed" do
    before do
      Storey.create "foobar"
    end

    context "with a block passed" do
      it "should execute the block in the default schema" do
        Storey.switch "foobar"
        Storey.switch { Post.create }
        Post.count.should be_zero
        Storey.switch { Post.count.should == 1 }
      end

      it "should return to the schema that the app was previously in" do
        Storey.switch "foobar"
        Storey.switch do; end
        Storey.schema.should == "foobar"
      end
    end

    context "without a block passed" do
      it "should switch the context to the default schema" do
        Storey.switch "foobar"
        Storey.switch
        Storey.schema.should == %{"$user",public}
      end
    end
  end

  context 'when persitent schemas are set' do

    context 'when suffixes are not set' do
      before do
        Storey.create 'foobar'
        persistent_schemas = %w(handle bar foo)
        persistent_schemas.each do |schema|
          Storey.create schema
        end
        Storey.persistent_schemas = persistent_schemas
      end

      it 'should switch to the schema with the persitent schemas still in the search path' do
        Storey.switch 'foobar'
        Storey.schema.should == %{foobar,handle,bar,foo}

        Storey.switch
        Storey.schema.should == %{"$user",public,handle,bar,foo}
      end
    end

    context 'when suffixes are set' do
      before do
        Storey.suffix = '_boomboom'
        Storey.create 'foobar'
        persistent_schemas = %w(handle bar foo)
        persistent_schemas.each do |schema|
          Storey.create schema
        end
        Storey.persistent_schemas = persistent_schemas
      end

      it 'should switch to the schema with the persitent schemas still in the search path' do
        Storey.switch 'foobar'
        Storey.schema.should == %{foobar,handle,bar,foo}

        Storey.switch
        Storey.schema.should == %{"$user",public,handle,bar,foo}
      end
    end

    context 'when switching to one of the persistent schemas' do
      before do
        persistent_schemas = %w(handle bar foo)
        persistent_schemas.each do |schema|
          Storey.create schema
        end
        Storey.persistent_schemas = persistent_schemas
      end

      it 'should not have duplicate schemas in the search path' do
        Storey.switch 'bar'
        Storey.schema.should == %{bar,handle,foo}
      end
    end

  end
end
