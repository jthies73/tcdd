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

ActiveRecord::Schema[8.0].define(version: 2025_02_06_151443) do
  create_table "clean_ups", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "status", default: "created", null: false
    t.datetime "starts_at"
    t.string "address"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "participants", force: :cascade do |t|
    t.string "name"
    t.integer "people_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "participations", force: :cascade do |t|
    t.string "status", default: "registered", null: false
    t.datetime "started_at"
    t.datetime "returned_at"
    t.integer "steps_count"
    t.integer "cigarettes_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "clean_up_id", null: false
    t.integer "participant_id", null: false
    t.index ["clean_up_id"], name: "index_participations_on_clean_up_id"
    t.index ["participant_id"], name: "index_participations_on_participant_id"
  end

  add_foreign_key "participations", "clean_ups"
  add_foreign_key "participations", "participants"
end
