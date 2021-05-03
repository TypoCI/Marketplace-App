# Preview all emails at http://localhost:3000/rails/mailers/github/install
class Github::InstallPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/github/install/shutdown
  def shutdown
    Github::InstallMailer.with(install: Github::Install.last).shutdown
  end
end
