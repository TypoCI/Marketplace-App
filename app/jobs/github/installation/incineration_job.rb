class Github::Installation::IncinerationJob < ApplicationJob
  queue_as :github__installation__incineration

  def perform(install)
    install.destroy!
  end
end
