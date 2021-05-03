namespace :heroku do
  desc "Run an ActiveJob - Called within one off dynos, normally via the API"
  task run_active_job: [:environment] do
    job_class = ENV["ONE_OFF_JOB_CLASS"]
    json_arguments = ENV["ONE_OFF_JOB_ARGUMENTS"]

    raise "Bad Arguments" if job_class.nil? || json_arguments.nil?

    Rails.logger.info("[rake heroku:run_active_job][#{job_class}] starting with #{json_arguments.inspect}")

    job_arguments = ActiveJob::Arguments.deserialize(JSON.parse(json_arguments))

    job_class.constantize.perform_now(*job_arguments)

    Rails.logger.info("[rake heroku:run_active_job][#{job_class}] done")
  end
end
