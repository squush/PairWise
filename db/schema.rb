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

ActiveRecord::Schema[7.0].define(version: 2022_11_28_204914) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "location"
    t.date "date"
    t.integer "rounds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "xtables_id"
    t.integer "number_of_players"
  end

  create_table "matchups", force: :cascade do |t|
    t.integer "round_number"
    t.integer "player1_score", default: 0
    t.integer "player2_score", default: 0
    t.bigint "player1_id", null: false
    t.bigint "player2_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "done", default: false
    t.index ["player1_id"], name: "index_matchups_on_player1_id"
    t.index ["player2_id"], name: "index_matchups_on_player2_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "rating"
    t.integer "ranking"
    t.float "win_count", default: 0.0
    t.integer "division"
    t.integer "crosstables_id"
    t.bigint "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "seed"
    t.boolean "active", default: true
    t.float "loss_count", default: 0.0
    t.integer "spread", default: 0
    t.index ["tournament_id"], name: "index_players_on_tournament_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.string "location"
    t.date "date"
    t.integer "rounds"
    t.integer "number_of_winners"
    t.integer "pairing_system", default: 10
    t.bigint "user_id", null: false
    t.bigint "event_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_tournaments_on_event_id"
    t.index ["user_id"], name: "index_tournaments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.string "username"
    t.integer "crosstables_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "matchups", "players", column: "player1_id"
  add_foreign_key "matchups", "players", column: "player2_id"
  add_foreign_key "players", "tournaments"
  add_foreign_key "tournaments", "events"
  add_foreign_key "tournaments", "users"
end
