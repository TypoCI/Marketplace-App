class Identity < ApplicationRecord
  attr_encrypted :access_token, key: :attr_encrypted_key
  attr_encrypted :refresh_token, key: :attr_encrypted_key

  belongs_to :user

  enum provider: {
    github: 'github'
  }

  validates :provider, presence: true
  validates :uid, presence: true

  scope :from_omniauth, ->(auth) { where(provider: auth.provider, uid: auth.uid) }

  def avatar_url
    "https://avatars3.githubusercontent.com/u/#{uid}"
  end

  # It expires in 8 hours time, so make sure we refresh in 7.
  def encrypted_access_token=(value)
    self.access_token_expires_at = Time.zone.now + 7.hours
    super
  end

  # It expires in 6 months time, so expire it in 5 to force a login.
  def encrypted_refresh_token=(value)
    self.refresh_token_expires_at = Time.zone.now + 5.months
    super
  end

  def installs
    Github::Install
      .account_is_an_organization_or_for_user_with_uid(uid)
      .where(install_id: list_installs.collect(&:id))
  end

  def list_installs
    github_oauth_service.installations
  end

  def list_repositories(install_id, page: 0)
    github_oauth_service.list_repositories(install_id, page: page)
  end

  def github_oauth_service
    @github_oauth_service ||= GithubOauthService.new(access_token, refresh_token)
  end

  def access_token_expired?
    access_token_expires_at <= Time.zone.now
  end

  private

  def attr_encrypted_key
    @attr_encrypted_key ||= ENV['ATTR_ENCRYPTED_KEY']
  end
end
