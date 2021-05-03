class Github::CheckSuites::IncinerationJob < ApplicationJob
  queue_as :github__check_suites__incineration

  def perform
    Github::CheckSuite.ready_for_incineration.destroy_all
  end
end
