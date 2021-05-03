class AddPlanToGithubInstalls < ActiveRecord::Migration[6.0]
  def change
    add_column :github_installs, :plan_id, :integer
    add_column :github_installs, :plan_name, :string
    add_column :github_installs, :on_free_trial, :boolean
    add_column :github_installs, :free_trial_ends_on, :date
    add_column :github_installs, :next_billing_on, :date
  end
end
