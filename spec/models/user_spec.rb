require 'rails_helper'

RSpec.describe User, type: :model do
  let(:instance_class) { described_class.new(name: 'MikeRogers0') }

  describe '#to_s' do
    subject { instance_class.to_s }

    it { is_expected.to eq('MikeRogers0') }
  end
end
