class Github::CheckSuites::AnalysisJob < ApplicationJob
  queue_as do
    github_check_suite = arguments.first

    if github_check_suite.pull_request?
      'github__check_suites__analysis--pull_request'
    elsif github_check_suite.committed_to_default_branch?
      'github__check_suites__analysis--default_branch'
    else
      'github__check_suites__analysis'
    end
  end

  # We can safely ignore repos that return 404's - we don't have access anymore.
  discard_on Octokit::NotFound do |job, _error|
    github_check_suite = job.arguments.first
    github_check_suite.conclusion_failure!
  end

  def perform(github_check_suite)
    @github_check_suite = github_check_suite

    if @github_check_suite.analysable?
      check_for_typos!
      update_github_check_suite!
      Github::CheckSuites::UpdateRemoteJob.perform_later(github_check_suite)
    else
      @github_check_suite.conclusion_skipped!
    end
  end

  private

  def check_for_typos!
    @started_at = Time.zone.now
    annotations # This actually does the check & loads them into memory.
    @completed_at = Time.zone.now
  end

  def update_github_check_suite!
    # Save the results and some stats to the check suite.
    @github_check_suite.update!(
      status: :completed,
      conclusion: analysis_service.conclusion,
      started_at: @started_at.iso8601,
      completed_at: @completed_at.iso8601,
      files_analysed_count: analysis_service.files_analysed_count,
      spelling_mistakes_count: analysis_service.spelling_mistakes_count,
      invalid_words: analysis_service.invalid_words,
      queuing_duration: queuing_duration,
      processing_duration: processing_duration,
      annotations: annotations,
      file_name_extensions: analysis_service.file_name_extensions
    )
  end

  def annotations
    @annotations ||= analysis_service.annotations
  end

  def queuing_duration
    @started_at.to_i - initially_enqueued_at.to_i
  end

  def processing_duration
    @completed_at.to_i - @started_at.to_i
  end

  def analysis_service
    @analysis_service ||= Github::CheckSuites::AnalysisService.new(@github_check_suite)
  end

  def install
    @install ||= @github_check_suite.install
  end

  def install_service
    @install_service ||= Github::InstallService.new(install)
  end
end
