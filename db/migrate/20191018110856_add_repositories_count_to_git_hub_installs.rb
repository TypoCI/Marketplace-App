class AddRepositoriesCountToGitHubInstalls < ActiveRecord::Migration[6.0]
  def change
    add_column :github_installs, :repositories_count, :integer, default: 0
  end
end
