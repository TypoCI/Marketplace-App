class Github::Install < ApplicationRecord
  has_many :check_suites, dependent: :destroy, foreign_key: :github_install_id, class_name: "Github::CheckSuite"

  validates :account_id, presence: true
  validates :account_type, presence: true
  validates :account_login, presence: true
  validates :app_id, presence: true
  validates :install_id, presence: true, uniqueness: true

  def self.account_is_an_organization_or_for_user_with_uid(uid)
    query = <<-SQL
    (
      "github_installs"."account_type" = 'Organization' OR (
        "github_installs"."account_type" = 'User' AND
        "github_installs"."account_id" = ?
      )
    )
    SQL
    where(query, uid)
  end

  def to_s
    ["app_id:#{app_id}", "install_id:#{install_id}", "account_login:#{account_login}"].join(",")
  end

  def plan
    @plan ||= Github::Plan.find(plan_id)
  end

  def organization?
    account_type == "Organization"
  end

  def upgrade_plan
    @upgrade_plan ||= if organization?
      Github::Plan.organization
    else
      Github::Plan.user
    end
  end
end
