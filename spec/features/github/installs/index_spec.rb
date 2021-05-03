require 'rails_helper'

RSpec.describe 'Github::Installs - Index', type: :feature do
  subject { visit root_url(subdomain: 'app') }

  let(:user) { create(:user) }

  before do
    login_as user
  end

  it 'With installs in the app' do
    stub_github_api('user/installations') do |json|
      json['installations'].each do |installation|
        create(:github_install, install_id: installation['id'])
      end
    end

    subject
    expect(page).to have_http_status(:success)
  end
end
