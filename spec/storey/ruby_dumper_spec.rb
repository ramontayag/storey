require 'spec_helper'

describe Storey::RubyDumper do

  describe '.dump' do
    it 'should create a db/schema.rb file' do
      schema_rb_path = File.join(Rails.root, 'db', 'schema.rb')
      FileUtils.rm(schema_rb_path) if File.exists?(schema_rb_path)
      dumper = described_class.new
      dumper.dump
      File.should exist(schema_rb_path)
      FileUtils.rm(schema_rb_path) if File.exists?(schema_rb_path)
    end

    context 'given a file is specified' do
      it 'should create the schema dump file in the specified location' do
        schema_rb_path = File.join(Rails.root, 'db', 'schema2.rb')
        FileUtils.rm(schema_rb_path) if File.exists?(schema_rb_path)
        dumper = described_class.new(file: schema_rb_path)
        dumper.dump
        File.should exist(schema_rb_path)
        FileUtils.rm(schema_rb_path) if File.exists?(schema_rb_path)
      end
    end
  end

end
