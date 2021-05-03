class Webhooks::Github::PullRequest
  def initialize(payload)
    @payload = payload
  end

  def opened!
    github_check_suite = install.check_suites.find_or_create_by!(
      head_branch: pull_request[:head][:ref],
      head_sha: pull_request[:head][:sha],
      base_sha: pull_request[:base][:sha],
      repository_full_name: repository[:full_name]
    ) do |new_github_check_suite|
      new_github_check_suite.repository_private = repository[:private]
      new_github_check_suite.repository_fork = repository[:fork]
      new_github_check_suite.repository_language = repository[:language]
      new_github_check_suite.github_id = "pull_request-#{pull_request[:node_id]}"
      new_github_check_suite.default_branch = repository[:default_branch]
      new_github_check_suite.sender_login = sender[:login]
      new_github_check_suite.sender_type = sender[:type]
    end
    github_check_suite.pull_requests_data = [Github::PullRequest.new(pull_request.to_h).to_h]
    github_check_suite.save!

    Github::CheckSuites::RequestedJob.perform_later(github_check_suite)
  end

  def synchronize!
    opened!
  end

  private

  def installation
    @payload[:installation]
  end

  def pull_request
    @payload["pull_request"]
  end

  def sender
    @payload["sender"]
  end

  def repository
    @payload["repository"]
  end

  def install
    @install ||= Github::Install.find_by!(install_id: installation["id"])
  end
end
