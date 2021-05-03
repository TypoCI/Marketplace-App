class Webhooks::Github::CheckSuite
  def initialize(payload)
    @payload = payload
  end

  def requested!
    # Skip any pull requests, they're handled by the pull request PR.
    return if github_check_suite.pull_request?
    return if head_commit_timestamp <= 1.month.ago

    github_check_suite.save!
    Github::CheckSuites::RequestedJob.perform_later(github_check_suite)
  end

  def rerequested!
    # I think has been deprecated by GitHub.
  end

  private

  def installation
    @payload[:installation]
  end

  def repository
    @payload[:repository]
  end

  def check_suite
    @payload[:check_suite]
  end

  def head_commit_timestamp
    Time.parse(check_suite[:head_commit][:timestamp])
  end

  def sender
    @payload[:sender]
  end

  def pull_requests
    check_suite["pull_requests"]
  end

  def github_check_suite
    @github_check_suite ||= install.check_suites.find_or_initialize_by(github_id: "check_suite-#{check_suite["id"]}") do |new_github_check_suite|
      new_github_check_suite.head_branch = check_suite[:head_branch]
      new_github_check_suite.head_sha = check_suite[:head_sha]
      new_github_check_suite.base_sha = check_suite[:before]
      new_github_check_suite.repository_full_name = repository[:full_name]
      new_github_check_suite.repository_private = repository[:private]
      new_github_check_suite.repository_fork = repository[:fork]
      new_github_check_suite.repository_language = repository[:language]
      new_github_check_suite.default_branch = repository[:default_branch]

      new_github_check_suite.sender_login = sender[:login]
      new_github_check_suite.sender_type = sender[:type]
      new_github_check_suite.pull_requests_data = pull_requests_data
    end
  end

  def pull_requests_data
    pull_requests.collect do |pull_request|
      Github::PullRequest.new(pull_request.to_h).to_h
    end
  end

  def install
    @install ||= Github::Install.find_by!(install_id: installation["id"])
  end
end
