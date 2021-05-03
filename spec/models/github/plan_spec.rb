require 'rails_helper'

RSpec.describe Github::Plan, type: :model do
  let(:instance) { described_class.new }

  describe '#private_repositories?' do
    subject { instance.private_repositories? }

    it { is_expected.to eq(false) }

    context 'private_repositories is true' do
      let(:instance) { described_class.new(private_repositories: true) }

      it { is_expected.to eq(true) }
    end
  end
end
