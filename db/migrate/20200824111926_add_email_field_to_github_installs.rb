class AddEmailFieldToGithubInstalls < ActiveRecord::Migration[6.0]
  def change
    add_column :github_installs, :email, :string
  end
end
