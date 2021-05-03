class AddAnalysisFieldsToGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :annotations, :jsonb
  end
end
