class AddDefaultBranchToGithubCheckSuite < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :default_branch, :string, default: "master"
  end
end
