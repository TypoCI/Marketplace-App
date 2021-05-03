class AddRepoLanguageToGithubCheckSuite < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :repository_language, :string
  end
end
