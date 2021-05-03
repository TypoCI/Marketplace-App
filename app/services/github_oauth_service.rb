class GithubOauthService
  def initialize(access_token, refresh_token)
    @access_token = access_token
    @refresh_token = refresh_token
  end

  def client
    @client ||= Octokit::Client.new(access_token: @access_token)
  end

  def installations
    client.get('user/installations', accept: 'application/vnd.github.machine-man-preview+json').installations || []
  end

  def list_repositories(account_login, page: 0)
    client.find_installation_repositories_for_user(account_login,
                                                   accept: 'application/vnd.github.machine-man-preview+json', page: page)
  end
end
