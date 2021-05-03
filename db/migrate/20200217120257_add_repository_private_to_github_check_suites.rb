class AddRepositoryPrivateToGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :repository_private, :boolean
  end
end
