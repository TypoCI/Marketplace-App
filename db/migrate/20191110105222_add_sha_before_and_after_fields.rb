class AddShaBeforeAndAfterFields < ActiveRecord::Migration[6.0]
  def change
    add_column :github_check_suites, :base_sha, :string
  end
end
