class Webhooks::Github::Installation
  def initialize(payload)
    @payload = payload
  end

  def created!
    @github_install = Github::Install.find_or_create_by!(install_id: installation["id"],
                                                         app_id: installation["app_id"]) do |new_install|
      new_install.account_id = installation["account"]["id"]
      new_install.account_type = installation["account"]["type"]
      new_install.account_login = installation["account"]["login"]
      new_install.repositories_count = repositories.count
    end
    Github::Installation::AnalyseAllPullRequestsJob.perform_later(@github_install)
    Github::Installation::UpdateMarketplacePurchaseJob.perform_later(@github_install)
  end

  def deleted!
    Github::Installation::IncinerationJob.perform_later(github_install)
  end

  private

  def installation
    @payload[:installation]
  end

  def repositories
    @payload[:repositories]
  end

  # Queue up a thank you email?!
  def sender
    @payload[:sender]
  end

  def github_install
    @github_install ||= Github::Install.find_by!(install_id: installation["id"], app_id: installation["app_id"])
  end
end
