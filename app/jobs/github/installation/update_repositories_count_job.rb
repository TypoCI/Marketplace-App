class Github::Installation::UpdateRepositoriesCountJob < ApplicationJob
  queue_as :github__installation__update_repositories_count

  def perform(install)
    @install = install
    install.update!(repositories_count: repositories.count)
  end

  def repositories
    @repositories ||= github_install_service.list_repositories
  end

  def github_install_service
    @github_install_service ||= Github::InstallService.new(@install)
  end
end
