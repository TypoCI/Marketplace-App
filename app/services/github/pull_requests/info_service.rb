class Github::PullRequests::InfoService
  def initialize(github_check_suite)
    @github_check_suite = github_check_suite
  end

  def pull_request_user_login
    pull_request[:user][:login]
  end

  def pull_request_user_type
    pull_request[:user][:type]
  end

  private

  def pull_request
    @pull_request ||= github_install_service.get_pull_request(@github_check_suite.pull_request.base_repo_full_name,
                                                              @github_check_suite.pull_request.number)
  end

  def github_install_service
    @github_install_service ||= Github::InstallService.new(@github_check_suite.install)
  end
end
