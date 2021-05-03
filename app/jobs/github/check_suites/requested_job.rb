# Checks if we can analyse the commit, then loads the configuration information.
# If we can perform the analysis, it'll kick off the AnalysisJob.
class Github::CheckSuites::RequestedJob < ApplicationJob
  queue_as :github__check_suites__requested

  # We can safely ignore repos that return 404's - we don't have access anymore.
  discard_on Octokit::NotFound do |job, _error|
    github_check_suite = job.arguments.first
    github_check_suite.conclusion_failure!
  end

  def perform(github_check_suite)
    @github_check_suite = github_check_suite

    # If we can't analyse this (e.g. it's a bot commit) skip it.
    unless @github_check_suite.analysable?
      @github_check_suite.conclusion_skipped!
      return
    end

    # Does their plan support this commit?
    unless @github_check_suite.plan_permits_analysis?
      @github_check_suite.conclusion_skipped!(conclusion_skipped_reason: "private_repositories_not_supported")
      Github::CheckSuites::SkipReasonUpdateRemoteJob.perform_later(@github_check_suite)
      return
    end

    # Check if the PR was made by a bot
    load_pull_request_information!
    unless @github_check_suite.pull_request_analysable?
      @github_check_suite.conclusion_skipped!(conclusion_skipped_reason: "unanalysable_pull_request")
      return
    end

    load_configuration!
    update_github_check_suite!

    Heroku::RunCommandJob.perform_later("Github::CheckSuites::AnalysisJob", @github_check_suite)
  end

  private

  def load_pull_request_information!
    return unless @github_check_suite.pull_request?

    @github_check_suite.update!(
      pull_request_user_login: pull_request_info_service.pull_request_user_login,
      pull_request_user_type: pull_request_info_service.pull_request_user_type
    )
  end

  def load_configuration!
    configuration_service.configuration
  end

  def update_github_check_suite!
    @github_check_suite.update!(
      status: :in_progress,
      custom_configuration_file: configuration_service.custom_configuration_file?,
      custom_configuration_valid: configuration_service.custom_configuration_valid?,
      custom_configuration: configuration_service.configuration.to_h
    )
  end

  def pull_request_info_service
    @pull_request_info_service ||= Github::PullRequests::InfoService.new(@github_check_suite)
  end

  def configuration_service
    @configuration_service ||= Github::CheckSuites::ConfigurationService.new(@github_check_suite)
  end
end
