namespace :github do
  namespace :installs do
    desc "Update details of all the Github::Installs"
    task update_all_details: :environment do
      Github::Install.find_each do |github_install|
        Github::Installation::UpdateDetailsJob.perform_later(github_install)
      end
    end

    desc "Update Marketplace Purchase details of all the Github::Installs"
    task update_marketplace_purchases: :environment do
      Github::Install.find_each do |github_install|
        Github::Installation::UpdateMarketplacePurchaseJob.perform_later(github_install)
      end
    end

    desc "Update Emails addresses of all the Github::Installs"
    task update_email_addresses: :environment do
      Github::Install.find_each do |github_install|
        Github::Installation::UpdateEmailAddressJob.perform_later(github_install)
      end
    end

    desc "Announce shutdown to all GitHub::Installs we have emails for"
    task deliver_shutdown_emails: :environment do
      Github::Install.where.not(email: nil).find_each do |github_install|
        Github::InstallMailer.with(install: github_install).shutdown.deliver_later
      end
    end
  end
end
