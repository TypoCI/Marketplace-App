class Github::InstallMailer < ApplicationMailer
  def shutdown
    @install = params[:install]

    mail to: @install.email
  end
end
