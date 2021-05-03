class Webhooks::Github::InstallationRepositories
  def initialize(payload)
    @payload = payload
  end

  def added!
    Github::Installation::UpdateRepositoriesCountJob.perform_later(install)

    repositories_added.each do |repository|
      Github::Repository::AnalysePullRequestsJob.perform_later(install, repository[:full_name])
    end
  end

  def removed!
    Github::Installation::UpdateRepositoriesCountJob.perform_later(install)
  end

  private

  def installation
    @payload[:installation]
  end

  def sender
    @payload[:sender]
  end

  def repositories_added
    @payload[:repositories_added]
  end

  def repositories_removed
    @payload[:repositories_removed]
  end

  def install
    @install ||= Github::Install.find_by!(install_id: installation["id"], app_id: installation["app_id"])
  end
end
