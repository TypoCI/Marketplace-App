class AddTimingsFieldsToGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :queuing_duration, :bigint
    add_column :github_check_suites, :processing_duration, :bigint
  end
end
