class Webhooks::GithubController < ActionController::API
  include GithubWebhook::Processor

  # Just for now skip these from github_webhook gem, while I figure out all the tests I need to write for this.
  skip_before_action :check_github_event!

  def github_installation(payload)
    Webhooks::Github::Installation.new(payload).created! if payload[:action] == "created"
    Webhooks::Github::Installation.new(payload).deleted! if payload[:action] == "deleted"
    # TODO: new_permissions_accepted
  end

  def github_integration_installation(payload)
    # Deprecated - I just wanted to stop HTTP errors.
  end

  def github_installation_repositories(payload)
    Webhooks::Github::InstallationRepositories.new(payload).added! if payload[:action] == "added"
    Webhooks::Github::InstallationRepositories.new(payload).removed! if payload[:action] == "removed"
  end

  def github_integration_installation_repositories(payload)
    # Deprecated - I just wanted to stop HTTP errors.
  end

  def github_marketplace_purchase(payload)
    Webhooks::Github::MarketplacePurchase.new(payload).purchased! if payload[:action] == "purchased"
    Webhooks::Github::MarketplacePurchase.new(payload).pending_change! if payload[:action] == "pending_change"
    Webhooks::Github::MarketplacePurchase.new(payload).changed! if payload[:action] == "changed"
  end

  def github_check_suite(payload)
    Webhooks::Github::CheckSuite.new(payload).requested! if payload[:action] == "requested"
    Webhooks::Github::CheckSuite.new(payload).rerequested! if payload[:action] == "rerequested"
  end

  def github_status(payload)
    # When status changes, often by us.
  end

  def github_github_app_authorization(payload)
    # When someone revokes their oAuth token.
  end

  def github_check_run(payload)
    Webhooks::Github::CheckRun.new(payload).requested_action! if payload[:action] == "requested_action"
  end

  def github_repository_event(payload)
    # A repo is created/renamed/deleted
    # https://developer.github.com/v3/activity/events/types/#repositoryevent
  end

  def github_organization(payload)
    # Someone is removed from the repo.
  end

  def github_organization_event(payload)
    # Someone is added/removed from an organisation, or an organisation is renamed
    # https://developer.github.com/v3/activity/events/types/#organizationevent
  end

  def github_repository(payload)
    # Repo changed or something.
  end

  def github_pull_request(payload)
    Webhooks::Github::PullRequest.new(payload).opened! if payload[:action] == "opened"
    Webhooks::Github::PullRequest.new(payload).synchronize! if payload[:action] == "synchronize"
  end

  private

  def webhook_secret(_payload)
    ENV["GITHUB_WEBHOOK_SECRET"]
  end
end
