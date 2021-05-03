class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked
  retry_on Octokit::InternalServerError, wait: :exponentially_longer, attempts: 8
  retry_on Octokit::BadGateway, wait: :exponentially_longer, attempts: 8
  retry_on Octokit::Unauthorized, wait: :exponentially_longer, attempts: 8
  retry_on Faraday::ConnectionFailed, wait: :exponentially_longer, attempts: 8

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  attr_writer :initially_enqueued_at

  def initially_enqueued_at
    @initially_enqueued_at ||= Time.zone.now
  end

  def serialize
    super.merge("initially_enqueued_at" => initially_enqueued_at)
  end

  def deserialize(job_data)
    super
    self.initially_enqueued_at = Time.parse(ENV["INITIALLY_ENQUEUED_AT"] || job_data["initially_enqueued_at"])
  end
end
