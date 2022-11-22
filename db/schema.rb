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

ActiveRecord::Schema[7.0].define(version: 2022_11_22_195347) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "events", force: :cascade do |t|
    t.string "location"
    t.date "date"
    t.integer "rounds"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matchups", force: :cascade do |t|
    t.integer "round_number"
    t.integer "player1_score"
    t.integer "player2_score"
    t.bigint "player1_id", null: false
    t.bigint "player2_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player1_id"], name: "index_matchups_on_player1_id"
    t.index ["player2_id"], name: "index_matchups_on_player2_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "rating"
    t.integer "ranking"
    t.integer "win_count"
    t.integer "division"
    t.integer "crosstables_id"
    t.bigint "tournament_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "matchups", "players", column: "player1_id"
  add_foreign_key "matchups", "players", column: "player2_id"
  add_foreign_key "players", "tournaments"
  add_foreign_key "tournaments", "events"
  add_foreign_key "tournaments", "users"
end
