class ChangeReportedColumnToBeDateTimeOnGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    remove_column :github_check_suites, :reported, :boolean, default: false, null: false
    add_column :github_check_suites, :reported_at, :datetime
  end
end
