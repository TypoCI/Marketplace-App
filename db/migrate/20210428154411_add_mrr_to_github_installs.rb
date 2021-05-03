class AddMrrToGithubInstalls < ActiveRecord::Migration[6.1]
  def change
    add_column :github_installs, :mrr_in_cents, :bigint, default: 0
    add_column :github_installs, :billing_cycle, :string, default: 'monthly'
  end
end
