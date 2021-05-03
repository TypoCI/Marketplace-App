class Slack::UsageSummaryJob < ApplicationJob
  queue_as :slack__usage_summary

  def perform
    client.chat_postMessage(channel: 'typo-ci', text: text, as_user: true)
  end

  private

  def text
    [
      '📊📋 *Usage Summary* 📋📊',
      '',
      "Github Installs: #{Github::Install.count}",
      "Paid Github Installs: #{Github::Install.where(plan_id: premium_plan_ids).count}",
      "MRR in Cents: #{Github::Install.where(plan_id: premium_plan_ids).sum(:mrr_in_cents)}",
      '',
      '*Github Check Suites (Last 7 Days)*',
      "Created: #{github_check_suites_in_period.count}",
      "Completed: #{github_check_suites_in_period.status_completed.count}",
      "Average Queue Duration: #{queuing_duration_in_period} seconds",
      "Average Processing Duration: #{processing_duration_in_period} seconds",
      '',
      '*Conclusions:*',
      conclusions_from_period
    ].join("\n")
  end

  def client
    @client ||= Slack::Web::Client.new(token: ENV['SLACK_BOT_USER_OAUTH_ACCESS_TOKEN'])
  end

  def queuing_duration_in_period
    github_check_suites_in_period.where.not(queuing_duration: nil).average(:queuing_duration).to_i
  end

  def processing_duration_in_period
    github_check_suites_in_period.where.not(processing_duration: nil).average(:processing_duration).to_i
  end

  def conclusions_from_period
    Github::CheckSuite.conclusions.collect do |key, conclusion|
      "#{key.humanize}: #{github_check_suites_in_period.where(conclusion: conclusion).count}" if github_check_suites_in_period.where(conclusion: conclusion).count.positive?
    end.compact.join("\n")
  end

  def premium_plan_ids
    Github::Plan.all.select(&:private_repositories?).collect(&:id)
  end

  def github_check_suites_in_period
    Github::CheckSuite.where(created_at: [7.days.ago..Time.zone.now])
  end
end
