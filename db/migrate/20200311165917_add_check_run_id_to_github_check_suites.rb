class AddCheckRunIdToGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :check_run_id, :string
  end
end
