class Github::AppService
  def initialize(auto_paginate: false)
    @auto_paginate = auto_paginate
  end

  def client
    @client ||= Octokit::Client.new(bearer_token: jwt, auto_paginate: @auto_paginate)
  end

  private

  def private_key
    @private_key ||= OpenSSL::PKey::RSA.new(
      ENV["GITHUB_PRIVATE_KEY"].gsub('\n', "\n")
    )
  end

  def app_identifier
    ENV["GITHUB_APP_IDENTIFIER"]
  end

  def jwt
    @jwt ||= JWT.encode(
      {
        iat: Time.now.to_i,
        # JWT expiration time is (10 minute maximum), so set it to 9.
        exp: Time.now.to_i + (9 * 60),
        iss: app_identifier
      },
      private_key,
      "RS256"
    )
  end
end
