# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_28_154411) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "github_check_suites", force: :cascade do |t|
    t.bigint "github_install_id", null: false
    t.string "github_id", null: false
    t.string "head_sha", null: false
    t.string "head_branch", null: false
    t.string "repository_full_name", null: false
    t.string "status", default: "queued", null: false
    t.string "conclusion", default: "pending", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.bigint "files_analysed_count"
    t.bigint "spelling_mistakes_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "default_branch", default: "master"
    t.jsonb "pull_requests_data", default: []
    t.jsonb "invalid_words", default: []
    t.string "base_sha"
    t.boolean "custom_configuration_file", default: false
    t.boolean "custom_configuration_valid", default: false
    t.string "repository_language"
    t.boolean "repository_private"
    t.bigint "queuing_duration"
    t.bigint "processing_duration"
    t.string "sender_login"
    t.string "sender_type"
    t.string "check_run_id"
    t.datetime "reported_at"
    t.jsonb "annotations"
    t.jsonb "custom_configuration", default: {}
    t.jsonb "file_name_extensions", default: []
    t.string "conclusion_skipped_reason", default: "none"
    t.boolean "repository_fork", default: false
    t.string "pull_request_user_type"
    t.string "pull_request_user_login"
    t.index ["github_install_id"], name: "index_github_check_suites_on_github_install_id"
  end

  create_table "github_installs", force: :cascade do |t|
    t.string "app_id", null: false
    t.string "install_id", null: false
    t.string "account_login", null: false
    t.bigint "check_suites_count", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "repositories_count", default: 0
    t.integer "plan_id"
    t.string "plan_name"
    t.boolean "on_free_trial"
    t.date "free_trial_ends_on"
    t.date "next_billing_on"
    t.string "account_type"
    t.bigint "account_id"
    t.string "email"
    t.bigint "mrr_in_cents", default: 0
    t.string "billing_cycle", default: "monthly"
    t.index ["install_id"], name: "index_github_installs_on_install_id", unique: true
  end

  create_table "identities", force: :cascade do |t|
    t.string "provider", default: "github", null: false
    t.string "uid", null: false
    t.string "login"
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_access_token"
    t.string "encrypted_access_token_iv"
    t.string "encrypted_refresh_token"
    t.string "encrypted_refresh_token_iv"
    t.datetime "access_token_expires_at"
    t.datetime "refresh_token_expires_at"
    t.index ["provider", "uid"], name: "index_identities_on_provider_and_uid"
    t.index ["user_id"], name: "index_identities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "github_check_suites", "github_installs"
  add_foreign_key "identities", "users"
end
