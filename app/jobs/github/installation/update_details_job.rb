class Github::Installation::UpdateDetailsJob < ApplicationJob
  queue_as :github__installation__update_details

  def perform(install)
    @install = install

    @install.update!(
      account_login: installation[:account][:login],
      account_id: installation[:account][:id],
      account_type: installation[:account][:type]
    )
  end

  private

  def installation
    @installation ||= github_install_service.installation
  end

  def github_install_service
    @github_install_service ||= Github::InstallService.new(@install)
  end
end
