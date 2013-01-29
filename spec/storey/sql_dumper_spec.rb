require 'spec_helper'

describe Storey::SqlDumper do

  describe '#dump' do
    it 'should create a db/structure.sql file' do
      structure_path = File.join(Rails.root, 'db', 'structure.sql')
      FileUtils.rm(structure_path) if File.exists?(structure_path)
      described_class.new.dump
      File.should exist(structure_path)
      FileUtils.rm(structure_path)
    end

    context 'when the file is specified' do
      it 'should create dump into the given file' do
        structure_path = File.join(Rails.root, 'db', 'structure2.sql')
        FileUtils.rm(structure_path) if File.exists?(structure_path)
        dumper = described_class.new(file: structure_path)
        dumper.dump
        File.should exist(structure_path)
        FileUtils.rm structure_path
      end
    end
  end

end
