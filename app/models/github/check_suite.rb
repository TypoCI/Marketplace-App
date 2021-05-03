class Github::CheckSuite < ApplicationRecord
  BLOCKED_AUTHORS = %w[
    "tensorflow-copybara",
    "gatsbybot",
    "vlc-mirrorer",
    "speedy19830509" # User is shadow banned on GitHub
  ].freeze

  belongs_to :install, class_name: "Github::Install", foreign_key: :github_install_id, counter_cache: true

  enum status: {
    queued: "queued",
    in_progress: "in_progress",
    completed: "completed"
  }, _prefix: :status

  enum conclusion: {
    pending: "pending",
    success: "success",
    failure: "failure",
    neutral: "neutral",
    cancelled: "cancelled",
    timed_out: "timed_out",
    action_required: "action_required",
    skipped: "skipped"
  }, _prefix: :conclusion

  enum conclusion_skipped_reason: {
    none: "none",
    unanalysable: "unanalysable",
    unanalysable_pull_request: "unanalysable_pull_request",
    private_repositories_not_supported: "private_repositories_not_supported"
  }, _prefix: :conclusion_skipped_reason

  validates :github_id, presence: true
  validates :head_sha, presence: true
  validates :head_branch, presence: true
  validates :default_branch, presence: true
  validates :repository_full_name, presence: true
  validates :base_sha, presence: true

  scope :ready_for_incineration, -> { where(created_at: Time.at(0)..(Time.zone.now - 3.weeks)) }
  scope :reported, -> { where.not(reported_at: nil) }

  def pull_request?
    pull_requests.any?
  end

  def pull_request
    pull_requests.first
  end

  def analysable?
    return false if sender_login_banned?
    return false if head_branch == "gh-pages" && first_commit?
    return false if newer_commits_on_branch_from_sender_exist?

    true
  end

  def plan_permits_analysis?
    !repository_private? || (repository_private? && install.plan.private_repositories?)
  end

  def pull_requests
    @pull_requests ||= pull_requests_data.collect do |pull_request_data|
      Github::PullRequest.new(pull_request_data)
    end.select do |pull_request_object|
      pull_request_object.analysable?(repository_full_name)
    end
  end

  def committed_to_default_branch?
    head_branch == default_branch
  end

  def first_commit?
    base_sha == "0000000000000000000000000000000000000000"
  end

  def reported!
    touch(:reported_at)
  end

  def reported?
    reported_at.present?
  end

  def custom_configuration_present_and_invalid?
    custom_configuration_file? && !custom_configuration_valid?
  end

  def conclusion_skipped!(conclusion_skipped_reason: "unanalysable")
    update(
      conclusion_skipped_reason: conclusion_skipped_reason,
      conclusion: "skipped",
      status: "completed"
    )
  end

  def pull_request_analysable?
    return true unless repository_fork?
    return true unless pull_request?

    pull_request_user_type != "Bot"
  end

  private

  def newer_commits_on_branch_from_sender_exist?
    Github::CheckSuite.where(
      install: install,
      repository_full_name: repository_full_name,
      head_branch: head_branch,
      sender_login: sender_login,
      sender_type: sender_type,
      created_at: (created_at..Float::INFINITY)
    ).where.not(id: id).any?
  end

  def sender_login_banned?
    sender_type == "Bot" || sender_login.in?(BLOCKED_AUTHORS)
  end
end
