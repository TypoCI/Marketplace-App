class Github::Installation::UpdateMarketplacePurchaseJob < ApplicationJob
  queue_as :github__installation__update_marketplace_purchase

  def perform(install)
    @install = install

    if marketplace_plan.present?
      update_marketplace_data!
    else
      clear_marketplace_data!
    end
  end

  private

  def update_marketplace_data!
    @install.update!(
      plan_id: plan_accounting_for_pending_change[:plan][:id],
      plan_name: plan_accounting_for_pending_change[:plan][:name],
      on_free_trial: marketplace_plan[:marketplace_purchase][:on_free_trial],
      free_trial_ends_on: marketplace_plan[:marketplace_purchase][:free_trial_ends_on],
      next_billing_on: marketplace_plan[:marketplace_purchase][:next_billing_on],
      billing_cycle: marketplace_plan[:marketplace_purchase][:billing_cycle],
      mrr_in_cents: mrr_in_cents
    )
  end

  def clear_marketplace_data!
    @install.update!(
      plan_id: nil,
      plan_name: nil,
      on_free_trial: nil,
      free_trial_ends_on: nil,
      next_billing_on: nil,
      billing_cycle: "monthly",
      mrr_in_cents: 0
    )
  end

  def marketplace_plan
    @marketplace_plan ||= github_install_service.marketplace_plan
  end

  def plan_accounting_for_pending_change
    @plan_accounting_for_pending_change ||= if marketplace_pending_change_is_upgrade?
      marketplace_plan[:marketplace_pending_change]
    else
      marketplace_plan[:marketplace_purchase]
    end
  end

  def mrr_in_cents
    return 0 unless marketplace_plan[:marketplace_purchase][:is_installed]

    if marketplace_plan[:marketplace_purchase][:billing_cycle] == "monthly"
      marketplace_plan[:marketplace_purchase][:plan][:monthly_price_in_cents]
    else
      marketplace_plan[:marketplace_purchase][:plan][:yearly_price_in_cents] / 12
    end
  end

  def marketplace_pending_change_is_upgrade?
    return false unless marketplace_plan[:marketplace_pending_change]

    Github::Plan.find(marketplace_plan[:marketplace_pending_change][:plan][:id]).private_repositories?
  end

  def github_install_service
    @github_install_service ||= Github::InstallService.new(@install)
  end
end
