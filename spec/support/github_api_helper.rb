module GithubApiHelper
  def stub_github_api(request_path, method: :get, headers: {}, user: nil, &block)
    if user.present?
      headers.merge!(
        'Authorization': "token #{user.identity.access_token}"
      )
    end

    response = JSON.parse(Rails.root.join('spec', 'fixtures', 'files', 'requests', 'api.github.com',
                                          "#{request_path}.json").read).tap(&block).to_json

    stub_request(method, "https://api.github.com/#{request_path}")
      .to_return(status: 200, body: response, headers: { 'content-type': 'application/json; charset=utf-8' })
  end
end

RSpec.configure do |config|
  config.include GithubApiHelper, type: :feature
end
