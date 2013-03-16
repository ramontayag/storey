require 'spec_helper'

describe Storey::Duplicator do

  describe '#perform!' do
    context "when the dump is a failure" do
      it 'should raise an error' do
        duplicator = described_class.new('non-existent-will-fail-dump', 'new')
        expect {
          duplicator.perform!
        }.to raise_error(
          Storey::StoreyError,
          "There seems to have been a problem dumping `non-existent-will-fail-dump` to make a copy of it into `new`"
        )
      end
    end
  end

end
