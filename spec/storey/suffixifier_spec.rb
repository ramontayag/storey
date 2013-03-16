require 'spec_helper'

describe Storey::Suffixifier do

  describe '#suffixify' do
    subject do
      described_class.new(schema_name).suffixify
    end

    context 'suffixes have been turned on' do
      before { Storey.suffix = '_suff' }

      context 'when the schema given has not already been suffixified' do
        let(:schema_name) { 'boom' }
        it { should == 'boom_suff' }
      end

      context 'when the schema given has already been suffixified' do
        let(:schema_name) { 'boom_suff' }
        it { should == 'boom_suff' }
      end

      context 'when given comma separated schemas' do
        let(:schema_name) { '"$user",public,foo,bar,baz' }

        it 'should return a comma separted schema string with the non-native schemas suffixified' do
          subject.should == '"$user",public,foo_suff,bar_suff,baz_suff'
        end
      end
    end

    context 'suffixes are not on' do
      before { Storey.suffix = nil }
      let(:schema_name) { 'boom' }
      it { should == 'boom' }
    end
  end

end
