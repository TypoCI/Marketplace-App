class Github::Installation::SyncAllMarketplacePlansJob
  def perform
    list_all_accounts_by_plan do |marketplace_plan|
      install = Github::Install.find_by(account_id: marketplace_plan[:id])

      if install.present?
        Rails.logger.info("[Github::Installation::SyncAllMarketplacePlansJob] Updating: #{marketplace_plan[:login]}")

        Github::Installation::UpdateMarketplacePurchaseJob.perform_later(install)

        ##  The market plan logic is more complex. Instead of duplicating, we'll just queue it up in
        ## Github::Installation::UpdateMarketplacePurchaseJob
        # install.update(
        #   account_login: marketplace_plan[:login],
        #   account_type: marketplace_plan[:type],
        #   plan_id: marketplace_plan[:marketplace_purchase][:plan][:id],
        #   plan_name: marketplace_plan[:marketplace_purchase][:plan][:name],
        #   on_free_trial: marketplace_plan[:marketplace_purchase][:on_free_trial],
        #   free_trial_ends_on: marketplace_plan[:marketplace_purchase][:free_trial_ends_on],
        #   next_billing_on: marketplace_plan[:marketplace_purchase][:next_billing_on],
        #   email: marketplace_plan[:organization_billing_email] || install.email
        # )
      else
        Rails.logger.info("[Github::Installation::SyncAllMarketplacePlansJob] Skipping: #{marketplace_plan[:login]}")
      end
    end
  end

  private

  def list_all_accounts_by_plan(&block)
    plan_ids.each do |plan_id|
      github_app_service_client.list_accounts_for_plan(plan_id).each(&block)
    end
  end

  def plan_ids
    @plan_ids ||= github_app_service_client.list_plans.collect(&:id)
  end

  def github_app_service_client
    @github_app_service_client ||= Github::AppService.new(auto_paginate: true).client
  end
end
