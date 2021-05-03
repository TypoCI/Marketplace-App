module GithubWebhookHelper
  def post_github_webhook(request_body, headers)
    headers[:'X-Hub-Signature'] = create_github_signature(request_body)

    post webhooks_github_index_url(subdomain: :webhooks), params: request_body, headers: headers
  end

  private

  def create_github_signature(request_body)
    hmac_digest = OpenSSL::Digest.new("sha1")
    secret = ENV["GITHUB_WEBHOOK_SECRET"]
    "sha1=#{OpenSSL::HMAC.hexdigest(hmac_digest, secret, request_body)}"
  end
end

RSpec.configure do |config|
  config.include GithubWebhookHelper, type: :request
end
