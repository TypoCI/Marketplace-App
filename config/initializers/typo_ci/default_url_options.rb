# Enable serving of images, stylesheets, and JavaScripts from an asset server.
if ENV["ASSET_HOST"]
  Rails.application.config.action_controller.asset_host = ENV["ASSET_HOST"]
  Rails.application.config.action_mailer.asset_host = ENV["ASSET_HOST"]
elsif ENV["HEROKU_APP_NAME"].present?
  Rails.application.config.action_controller.asset_host = "https://#{ENV["HEROKU_APP_NAME"]}.herokuapp.com"
  Rails.application.config.action_mailer.asset_host = "https://#{ENV["HEROKU_APP_NAME"]}.herokuapp.com"
end

Rails.application.default_url_options = {
  host: ENV.fetch("URL", "typoci.test"),
  protocol: "https"
}

Rails.application.config.action_controller.default_url_options = {
  host: ENV.fetch("URL", "typoci.test"),
  protocol: "https"
}
