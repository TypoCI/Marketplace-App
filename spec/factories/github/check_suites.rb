FactoryBot.define do
  factory :github_check_suite, class: "Github::CheckSuite" do
    association :install, factory: :github_install

    sequence :github_id
    head_branch { "new-feature" }
    default_branch { "master" }
    head_sha { "ffe6c6ab64ec0e7cb9dca88b94452628e3d64276" }
    repository_full_name { "MikeRogers0/MikeRogersIO" }
    base_sha { "8f22da3d6c16f3291cd02e18bc40579558383d60" }
    repository_private { false }
    sender_login { "TypoCasualUser" }
    sender_type { "User" }

    pull_requests_data do
      [
        {
          url: "https://api.github.com/repos/MikeRogers0/MikeRogersIO/pulls/64",
          number: 64,
          head: {
            ref: "imgbot",
            sha: "ffe6c6ab64ec0e7cb9dca88b94452628e3d64276",
            repo: {
              id: 325_384,
              url: "https://api.github.com/users/MikeRogers0"
            }
          },
          base: {
            ref: "master",
            sha: "8f22da3d6c16f3291cd02e18bc40579558383d60",
            repo: {
              id: 11_435_930,
              url: "https://api.github.com/repos/MikeRogers0/MikeRogersIO"
            }
          }
        }
      ]
    end

    trait :repository_private do
      repository_private { true }
    end

    trait :analysed_no_typos do
      annotations { [] }
      spelling_mistakes_count { 0 }
      files_analysed_count { 0 }
    end

    trait :analysed_has_typos do
      annotations { [{annotation_level: :warning, body: '"TypoCI" is a typo'}] }
      spelling_mistakes_count { 1 }
      files_analysed_count { 1 }
    end

    trait :not_analysable do
      base_sha { "0000000000000000000000000000000000000000" }
      head_branch { "gh-pages" }
    end

    trait :not_analysable_as_plan_does_not_support_private do
      association :install, factory: %i[github_install with_open_source_plan]
      repository_private { true }
    end

    trait :skipped_because_its_on_wrong_plan do
      status { "completed" }
      conclusion { "skipped" }
      conclusion_skipped_reason { "private_repositories_not_supported" }
    end

    trait :first_commit do
      base_sha { "0000000000000000000000000000000000000000" }
    end

    trait :bot_commit do
      sender_login { "pull[bot]" }
      sender_type { "Bot" }
    end

    trait :committed_to_default_branch do
      pull_requests_data { [] }
      head_branch { "master" }
      default_branch { "master" }
    end

    trait :no_pull_requests do
      pull_requests_data { [] }
    end

    trait :with_analysis_performed do
      status { :completed }
      started_at { Time.zone.now }
      completed_at { Time.zone.now + 5.seconds }
      conclusion { :success }
      queuing_duration { 10 }
      processing_duration { 5 }
      files_analysed_count { 1 }
      spelling_mistakes_count { 0 }
      invalid_words { [] }
      custom_configuration_file { false }
      custom_configuration_valid { true }
    end

    trait :pr_on_fork_repo do
      repository_fork { true }
    end

    trait :pr_to_fork_repo do
      repository_fork { true }

      pull_requests_data do
        [
          {
            url: "https://api.github.com/repos/SomeoneElse/MikeRogersIO/pulls/64",
            number: 64,
            head: {
              ref: "imgbot",
              sha: "ffe6c6ab64ec0e7cb9dca88b94452628e3d64276",
              repo: {
                id: 325_384,
                url: "https://api.github.com/users/MikeRogers0"
              }
            },
            base: {
              ref: "master",
              sha: "8f22da3d6c16f3291cd02e18bc40579558383d60",
              repo: {
                id: 11_435_930,
                url: "https://api.github.com/repos/SomeoneElse/MikeRogersIO"
              }
            }
          }
        ]
      end
    end

    trait :reported do
      reported_at { Time.zone.now }
    end
  end
end
