class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :trackable, :lockable,
    :rememberable, :validatable, :omniauthable

  has_many :identities, dependent: :destroy

  def self.build_from_github_omniauth(auth)
    email_address = auth.info[:email].presence || "#{auth.info[:id]}+#{auth.info[:login]}@users.noreply.github.com"

    find_or_initialize_with_password_by(email: email_address, name: auth.info[:name])
  end

  def self.find_or_initialize_with_password_by(email:, name:)
    find_or_initialize_by(email: email) do |user|
      user.name = name
      user.password = Devise.friendly_token[0, 64]
    end
  end

  def avatar_url
    identities.first&.avatar_url || "face.svg"
  end

  def to_s
    name || "Awesome User"
  end

  def identity
    @identity ||= identities.first
  end

  def list_repositories(install_id, page: 0)
    identity.list_repositories(install_id, page: page)
  end

  def installs
    @installs ||= identity.installs
  end

  protected

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
