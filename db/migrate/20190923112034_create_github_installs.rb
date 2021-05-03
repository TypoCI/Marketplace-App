class CreateGithubInstalls < ActiveRecord::Migration[6.0]
  def change
    create_table :github_installs do |t|
      t.string :app_id, null: false
      t.string :install_id, null: false, index: { unique: true }
      t.string :account_login, null: false
      t.bigint :check_suites_count, default: 0

      t.timestamps
    end
  end
end
