class AddPullRequestUserTypeAndLoginToGithubCheckSuite < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :pull_request_user_type, :string
    add_column :github_check_suites, :pull_request_user_login, :string
  end
end
