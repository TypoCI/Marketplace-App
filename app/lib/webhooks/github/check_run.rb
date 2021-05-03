class Webhooks::Github::CheckRun
  def initialize(payload)
    @payload = payload
  end

  def requested_action!
    github_check_suite&.reported! if requested_action[:identifier] == 'reported'
  end

  private

  def installation
    @payload[:installation]
  end

  def check_run
    @payload[:check_run]
  end

  def requested_action
    @payload[:requested_action]
  end

  def github_check_suite
    @github_check_suite ||= GlobalID::Locator.locate(check_run[:external_id])
  end

  def install
    @install ||= Github::Install.find_by!(install_id: installation['id'])
  end
end
