require 'spec_helper'

describe Storey::NativeSchemaMatcher do

  describe '#matches?' do
    context 'when the schema is "$user"' do
      it 'should be true' do
        m = described_class.new('"$user"')
        m.matches?.should be_true
      end
    end

    context 'when the schema is public' do
      it 'should be true' do
        m = described_class.new('public')
        m.matches?.should be_true
      end
    end

    context 'when given comma separated string of schemas all matching' do
      it 'should be true' do
        m = described_class.new('"$user",public')
        m.matches?.should be_true
      end
    end

    context 'when the schema is neither "$user" or public' do
      it 'should be false' do
        m = described_class.new('something')
        m.matches?.should be_false
      end
    end
  end

end
