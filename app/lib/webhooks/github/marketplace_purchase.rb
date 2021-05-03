class Webhooks::Github::MarketplacePurchase
  def initialize(payload)
    @payload = payload
  end

  def purchased!
    return if github_install.blank?

    Github::Installation::UpdateMarketplacePurchaseJob.perform_later(github_install)
  end

  alias_method :pending_change!, :purchased!
  alias_method :changed!, :purchased!

  private

  def sender
    @payload[:sender]
  end

  def marketplace_purchase
    @payload[:marketplace_purchase]
  end

  def account
    marketplace_purchase[:account]
  end

  def github_install
    @github_install ||= Github::Install.find_by(account_id: account["id"])
  end
end
