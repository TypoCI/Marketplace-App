class AddAccountIdAndTypeToGithubInstalls < ActiveRecord::Migration[6.0]
  def change
    add_column :github_installs, :account_type, :string
    add_column :github_installs, :account_id, :bigint
  end
end
