class AddContainsFalsePositiveToGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :reported, :boolean, default: false, null: false
  end
end
