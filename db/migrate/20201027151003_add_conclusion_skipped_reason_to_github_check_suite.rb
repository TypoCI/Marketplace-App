class AddConclusionSkippedReasonToGithubCheckSuite < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :conclusion_skipped_reason, :string, default: "none"
  end
end
