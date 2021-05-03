class Github::Installation::AnalyseAllPullRequestsJob < ApplicationJob
  queue_as :github__installation__analyse_all_pull_requests

  def perform(install)
    @install = install

    repositories.each do |repository|
      Github::Repository::AnalysePullRequestsJob.perform_later(@install, repository[:full_name])
    end
  end

  private

  def repositories
    @repositories ||= github_install_service.list_repositories
  end

  def github_install_service
    @github_install_service ||= Github::InstallService.new(@install)
  end
end
