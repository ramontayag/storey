require 'spec_helper'

describe Storey::Unsuffixifier do

  describe '#unsuffixify' do
    subject { described_class.new(schema_name).unsuffixify }

    context 'when the suffix is set' do
      before { Storey.suffix = '_buff' }

      context 'when the schema name does not have a suffix' do
        let(:schema_name) { 'big' }
        it { should == 'big' }
      end

      context 'when the schema name has a suffix' do
        let(:schema_name) { 'big_buff' }
        it { should == 'big' }
      end

      context 'when the schema name is comma separated schemas' do
        let(:schema_name) { '"$user",public,froo_buff,la_buff' }
        it {should == '"$user",public,froo,la'}
      end
    end

    context 'when the suffix is not set' do
      let(:schema_name) { '"$user",public,froo_buff' }
      it { should == '"$user",public,froo_buff' }
    end
  end

end
