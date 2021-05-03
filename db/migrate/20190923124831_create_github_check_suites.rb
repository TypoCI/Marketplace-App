class CreateGithubCheckSuites < ActiveRecord::Migration[6.0]
  def change
    create_table :github_check_suites do |t|
      t.references :github_install, null: false, foreign_key: true
      t.string :github_id, null: false
      t.string :head_sha, null: false
      t.string :head_branch, null: false
      t.string :repository_full_name, null: false
      t.json :pull_request_numbers, default: []
      t.string :status, default: "queued", null: false
      t.string :conclusion, default: "pending", null: false
      t.datetime :started_at
      t.datetime :completed_at

      t.bigint :files_analysed_count
      t.bigint :spelling_mistakes_count

      t.timestamps
    end
  end
end
