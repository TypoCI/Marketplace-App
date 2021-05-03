class AddFileExtensionsToGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :file_name_extensions, :jsonb, default: []
  end
end
