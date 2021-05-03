class Github::Repository::AnalysePullRequestsJob < ApplicationJob
  queue_as :github__repository__analyse_pull_requests

  def perform(github_install, repository_full_name)
    @github_install = github_install
    @repository_full_name = repository_full_name

    check_suites = get_pull_requests_for_repository(repository_full_name).collect do |pull_request|
      next if pull_request[:updated_at] <= 1.month.ago || pull_request[:head][:repo].nil?

      repository = pull_request[:base][:repo]

      @github_install.check_suites.find_or_create_by!(
        head_branch: pull_request[:head][:ref],
        head_sha: pull_request[:head][:sha],
        base_sha: pull_request[:base][:sha],
        repository_full_name: repository[:full_name]
      ) do |new_github_check_suite|
        new_github_check_suite.repository_private = repository[:private]
        new_github_check_suite.repository_language = repository[:language]
        new_github_check_suite.github_id = "first_pull_request-#{pull_request[:node_id]}"
        new_github_check_suite.default_branch = repository[:default_branch]
        new_github_check_suite.sender_login = pull_request[:user][:login]
        new_github_check_suite.sender_type = pull_request[:user][:type]
        new_github_check_suite.pull_requests_data = [Github::PullRequest.new(pull_request.to_h).to_h]
      end
    end

    check_suites.compact.each do |github_check_suite|
      Github::CheckSuites::RequestedJob.perform_later(github_check_suite)
    end
  end

  private

  def get_pull_requests_for_repository(repository_full_name)
    github_install_service.list_open_pull_requests(repository_full_name)
  end

  def github_install_service
    @github_install_service ||= Github::InstallService.new(@github_install)
  end
end
