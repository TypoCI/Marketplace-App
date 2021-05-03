require 'rails_helper'

RSpec.describe Identity, type: :model do
  let(:instance_class) { described_class.new }

  describe '#access_token=' do
    subject { instance_class.access_token = 'Hello World' }

    it 'Sets encrypted_access_token' do
      expect { subject }.to change(instance_class, :encrypted_access_token).from(nil)
    end

    it 'Sets access_token_expires_at' do
      expect { subject }.to change(instance_class, :access_token_expires_at).from(nil).to(Time)
    end
  end

  describe '#access_token=' do
    subject { instance_class.refresh_token = 'Hello World' }

    it 'Sets encrypted_refresh_token' do
      expect { subject }.to change(instance_class, :encrypted_refresh_token).from(nil)
    end

    it 'Sets refresh_token_expires_at' do
      expect { subject }.to change(instance_class, :refresh_token_expires_at).from(nil).to(Time)
    end
  end
end
