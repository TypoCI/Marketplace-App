require 'platform-api'
require 'rendezvous'

# This lets us run ActiveJob jobs in a one off Heroku dyno.
class Heroku::RunCommandJob < ApplicationJob
  retry_on Rendezvous::Errors::ConnectionTimeout, wait: :exponentially_longer, attempts: 8
  queue_as :heroku__run_command

  def perform(job_class, *args)
    @job_class = job_class
    @args = args

    if ENV['HEROKU_APP_ID'].present?
      run_in_one_off_dyno!
    else
      ENV['ONE_OFF_JOB_CLASS'] = @job_class
      ENV['ONE_OFF_JOB_ARGUMENTS'] = job_arguments_serialised
      ENV['INITIALLY_ENQUEUED_AT'] = initially_enqueued_at.to_s
      job_arguments = ActiveJob::Arguments.deserialize(JSON.parse(job_arguments_serialised))
      job_class.constantize.perform_now(*job_arguments)
      ENV['ONE_OFF_JOB_CLASS'] = nil
      ENV['ONE_OFF_JOB_ARGUMENTS'] = nil
      ENV['INITIALLY_ENQUEUED_AT'] = nil
    end
  end

  private

  def run_in_one_off_dyno!
    dyno = platform_api.dyno.create(ENV['HEROKU_APP_ID'], {
                                      attach: true,
                                      env: {
                                        ONE_OFF_JOB_CLASS: @job_class,
                                        ONE_OFF_JOB_ARGUMENTS: job_arguments_serialised,
                                        INITIALLY_ENQUEUED_AT: initially_enqueued_at.to_s
                                      },
                                      time_to_live: 10.minutes.to_i,
                                      command: run_command
                                    })

    rendezvous = Rendezvous.new(input: StringIO.new, output: StringIO.new, url: dyno['attach_url'])
    rendezvous.start
    rendezvous.output.rewind

    rendezvous.output.readlines.each do |line|
      Rails.logger.info "[rendezvous]: #{line}"
    end
  end

  def run_command
    "bundle exec rake #{rake_command}"
  end

  def rake_command
    'heroku:run_active_job'
  end

  def job_arguments_serialised
    ActiveJob::Arguments.serialize(@args).to_json
  end

  def platform_api
    @platform_api ||= PlatformAPI.connect_oauth(ENV['HEROKU_OAUTH'])
  end
end
