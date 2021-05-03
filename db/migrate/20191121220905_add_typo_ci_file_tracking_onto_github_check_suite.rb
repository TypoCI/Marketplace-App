class AddTypoCiFileTrackingOntoGithubCheckSuite < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :custom_configuration_file, :boolean, default: false
    add_column :github_check_suites, :custom_configuration_valid, :boolean, default: false
  end
end
