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

ActiveRecord::Schema[8.0].define(version: 2025_04_16_211301) do
  create_table "factorio_servers", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "port"
    t.integer "rcon_port"
    t.string "rcon_password"
    t.integer "max_players"
    t.string "game_password"
    t.string "admin_password"
    t.boolean "auto_start"
    t.string "docker_container_id"
    t.string "status"
    t.string "version", default: "latest"
    t.string "save_file"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "visibility_public", default: true
    t.boolean "visibility_lan", default: true
    t.boolean "require_user_verification", default: true
    t.integer "max_upload_in_kilobytes_per_second", default: 0
    t.integer "max_upload_slots", default: 5
    t.integer "minimum_latency_in_ticks", default: 0
    t.boolean "ignore_player_limit_for_returning_players", default: false
    t.string "allow_commands", default: "admins-only"
    t.integer "autosave_interval", default: 10
    t.integer "autosave_slots", default: 5
    t.integer "afk_autokick_interval", default: 0
    t.boolean "auto_pause", default: true
    t.boolean "only_admins_can_pause_the_game", default: true
    t.boolean "autosave_only_on_server", default: true
    t.boolean "non_blocking_saving", default: false
    t.integer "minimum_segment_size", default: 25
    t.integer "minimum_segment_size_peer_count", default: 20
    t.integer "maximum_segment_size", default: 100
    t.integer "maximum_segment_size_peer_count", default: 10
    t.string "token"
    t.string "tags", default: "managed"
    t.boolean "enable_base", default: true
    t.boolean "enable_elevated_rails", default: true
    t.boolean "enable_quality", default: true
    t.boolean "enable_space_age", default: true
    t.boolean "auto_update_mods", default: false
    t.index ["name"], name: "index_factorio_servers_on_name", unique: true
    t.index ["port"], name: "index_factorio_servers_on_port", unique: true
    t.index ["rcon_port"], name: "index_factorio_servers_on_rcon_port", unique: true
    t.index ["user_id"], name: "index_factorio_servers_on_user_id"
  end

  create_table "game_logs", force: :cascade do |t|
    t.integer "factorio_server_id", null: false
    t.datetime "timestamp"
    t.text "message"
    t.string "log_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factorio_server_id"], name: "index_game_logs_on_factorio_server_id"
    t.index ["log_hash"], name: "index_game_logs_on_log_hash"
  end

  create_table "mods", force: :cascade do |t|
    t.integer "factorio_server_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "version"
    t.string "file_name"
    t.boolean "enabled", default: true
    t.index ["factorio_server_id"], name: "index_mods_on_factorio_server_id"
  end

  create_table "server_logs", force: :cascade do |t|
    t.integer "factorio_server_id", null: false
    t.string "level"
    t.text "message"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["factorio_server_id"], name: "index_server_logs_on_factorio_server_id"
  end

  create_table "site_settings", force: :cascade do |t|
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_site_settings_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "factorio_username"
    t.string "factorio_token"
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "factorio_servers", "users"
  add_foreign_key "game_logs", "factorio_servers"
  add_foreign_key "mods", "factorio_servers"
  add_foreign_key "server_logs", "factorio_servers"
end
