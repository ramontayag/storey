require 'spec_helper'

describe Storey::Dumper do

  describe '#dump' do
    it 'should dump the schema using the correct dumper' do
      special_dumper = double
      args = {}
      dumper = described_class.new(args)
      dumper.stub(:dumper).and_return(special_dumper)
      special_dumper.should_receive(:dump).once
      dumper.dump
    end
  end

  describe '#dumper' do
    it 'should be an instance of the dumper_class with the options passed through' do
      options = {:a => 'b'}
      dumper = described_class.new(options)
      dumper.dumper_class.should_receive(:new).with(options).and_return('dumper')
      dumper.dumper.should == 'dumper'
    end
  end

  describe '#dumper_class' do
    context 'when the schema_format is nil' do
      it 'should be RubyDumper' do
        Rails.configuration.active_record.schema_format = nil
        described_class.new.dumper_class.should == Storey::RubyDumper
      end
    end

    context 'when the schema_format is :ruby' do
      it 'should be RubyDumper' do
        Rails.configuration.active_record.schema_format = :ruby
        described_class.new.dumper_class.should == Storey::RubyDumper
      end
    end

    context 'when the schema_format is :sql' do
      it 'should be RubyDumper' do
        Rails.configuration.active_record.schema_format = :sql
        described_class.new.dumper_class.should == Storey::SqlDumper
      end
    end
  end

  # describe '.dump' do
  #   context 'when schema_format is not set' do
  #     it 'should default to dumping ruby format' do
  #       Rails.configuration.active_record.schema_format = nil
  #       described_class.should_receive(:dump_schema_rb).once
  #       described_class.dump
  #     end
  #   end

  #   context 'when the schema_format is :ruby' do
  #     before do
  #       Rails.configuration.active_record.schema_format = :ruby
  #     end

  #     it 'should create a db/schema.rb file' do
  #       schema_rb_path = File.join Rails.root, 'db', 'schema.rb'
  #       FileUtils.rm schema_rb_path if File.exists?(schema_rb_path)
  #       described_class.dump
  #       File.should exist(schema_rb_path)
  #       FileUtils.rm schema_rb_path if File.exists?(schema_rb_path)
  #     end

  #     context 'given a file is specified' do
  #       it 'should create the schema dump file in the specified location' do
  #         schema_rb_path = File.join Rails.root, 'db', 'schema2.rb'
  #         FileUtils.rm schema_rb_path if File.exists?(schema_rb_path)
  #         described_class.dump file: schema_rb_path
  #         File.should exist(schema_rb_path)
  #         FileUtils.rm schema_rb_path if File.exists?(schema_rb_path)
  #       end
  #     end
  #   end

  #   context 'when the schema_format is :sql' do
  #     before do
  #       Rails.configuration.active_record.schema_format = :sql
  #     end

  #     it 'should create a db/structure.sql file' do
  #       structure_path = File.join Rails.root, 'db', 'structure.sql'
  #       FileUtils.rm structure_path if File.exists?(structure_path)
  #       described_class.dump
  #       File.should exist(structure_path)
  #       FileUtils.rm structure_path
  #     end

  #     context 'when the file is specified' do
  #       it 'should create dump into the given file' do
  #         structure_path = File.join Rails.root, 'db', 'structure2.sql'
  #         FileUtils.rm structure_path if File.exists?(structure_path)
  #         described_class.dump file: structure_path
  #         File.should exist(structure_path)
  #         FileUtils.rm structure_path
  #       end
  #     end
  #   end
  # end
end
