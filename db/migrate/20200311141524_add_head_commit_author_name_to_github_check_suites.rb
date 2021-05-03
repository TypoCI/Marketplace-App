class AddHeadCommitAuthorNameToGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :sender_login, :string
    add_column :github_check_suites, :sender_type, :string
  end
end
