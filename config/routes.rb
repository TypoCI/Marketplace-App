Rails.application.routes.draw do
  # Have a path just for checking uptime, a no frills things to just check we're alive
  get :uptime_check, path: 'uptime-check', to: proc { [200, {}, ["Hello Robot - We're still up"]] }

  constraints subdomain: 'webhooks' do
    namespace :webhooks do
      resources :github, only: [:create], defaults: { formats: :json }
    end
    get '/', to: redirect("https://#{ENV['URL']}")
  end

  constraints subdomain: 'app' do
    devise_for :users,
               skip: %i[passwords unlocks],
               path_names: {
                 sign_in: 'sign-in',
                 sign_out: 'sign-out'
               }, controllers: {
                 sessions: 'users/sessions',
                 omniauth_callbacks: 'users/omniauth_callbacks'
               }

    resources :installs, only: [:show], module: :github

    get '', to: 'github/installs#index'
  end

  direct :contact do
    'https://typoci.com/contact'
  end

  direct :documentation do
    'https://typoci.com/documentation'
  end

  direct :setup do
    'https://typoci.com/setup'
  end

  direct :privacy_policy do
    'https://typoci.com/privacy-policy'
  end

  direct :terms_of_service do
    'https://typoci.com/terms-of-service'
  end

  direct :cookie_policy do
    'https://typoci.com/cookie-policy'
  end

  direct :subprocessors do
    'https://typoci.com/subprocessors'
  end

  direct :vulnerability_management_policy do
    'https://typoci.com/vulnerability-management-policy'
  end

  direct :incident_response_policy do
    'https://typoci.com/incident-response-policy'
  end

  direct :new_github_installation do
    if Rails.env.production?
      "https://github.com/marketplace/#{ENV['GITHUB_MARKETPLACE_SLUG']}"
    else
      "https://github.com/apps/#{ENV['GITHUB_APP_SLUG']}/installations/new"
    end
  end

  direct :github_installation do |args|
    "https://github.com/apps/#{ENV['GITHUB_APP_SLUG']}/installations/#{args[:install_id]}"
  end

  direct :github_change_plan do |args|
    "https://github.com/marketplace/#{ENV['GITHUB_MARKETPLACE_SLUG']}/upgrade/#{args[:upgrade_plan_id]}/#{args[:account_id]}"
  end

  mount Sidekiq::Web => '/sidekiq'

  # Letter Opener - See emails sent in the browser
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  root to: redirect("https://#{ENV['URL']}")
end
