class AddPullRequestsDataToGithubCheckSuite < ActiveRecord::Migration[6.0]
  def change
    remove_column :github_check_suites, :pull_request_numbers, :json, default: []
    add_column :github_check_suites, :pull_requests_data, :jsonb, default: []
  end
end
