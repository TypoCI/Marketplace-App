class AddConfigurationFieldToGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :custom_configuration, :jsonb, default: {}
  end
end
