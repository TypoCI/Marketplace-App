FactoryBot.define do
  factory :identity do
    provider { 'github' }
    sequence :uid
    association :user

    access_token { SecureRandom.uuid }
    access_token_expires_at { Time.now + 4.months }

    refresh_token { SecureRandom.uuid }
    refresh_token_expires_at { Time.now + 4.months }
  end
end
