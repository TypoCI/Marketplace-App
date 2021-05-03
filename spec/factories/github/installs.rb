FactoryBot.define do
  factory :github_install, class: "Github::Install" do
    app_id { "22929" }
    sequence :install_id

    account_login { Faker::Company.name }
    sequence :account_id
    account_type { "User" }

    repositories_count { 0 }

    trait :with_email do
      email { "sample@example.com" }
    end

    trait :organization do
      account_type { "Organization" }
    end

    trait :with_check_suite do
      after(:build) do |install|
        install.check_suites = build_list(:github_check_suite, 1, install: install)
      end
    end

    trait :with_plan do
      plan_id { 4979 }
      plan_name { "Organization" }
    end

    trait :with_open_source_plan do
      plan_id { 4980 }
      plan_name { "Open Source" }
    end
  end
end
