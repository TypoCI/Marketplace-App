class Github::Installation::UpdateEmailAddressJob < ApplicationJob
  queue_as :github__installation__update_install_email_address

  def perform(install)
    @install = install

    @install.update!(email: email) if email.present?
  end

  private

  def email
    @email ||= github_install_service.client.user(@install.account_login).email
  end

  def github_install_service
    @github_install_service ||= Github::InstallService.new(@install)
  end
end
