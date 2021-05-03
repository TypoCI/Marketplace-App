Rails.application.configure do
  if Rails.env.development?
    config.action_mailer.delivery_method = :letter_opener_web
    config.action_mailer.perform_deliveries = true
  elsif ENV["SMTP_USERNAME"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.smtp_settings = {
      address: "smtp.fastmail.com",
      port: "465",
      authentication: :plain,
      user_name: ENV["SMTP_USERNAME"],
      password: ENV["SMTP_PASSWORD"],
      domain: "typoci.com",
      enable_starttls_auto: true
    }
  end
end
