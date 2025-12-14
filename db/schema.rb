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

ActiveRecord::Schema[8.1].define(version: 2025_12_14_124715) do
  create_table "answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "field_id", null: false
    t.integer "response_id", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["field_id"], name: "index_answers_on_field_id"
    t.index ["response_id"], name: "index_answers_on_response_id"
  end

  create_table "fields", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "field_type"
    t.integer "form_id", null: false
    t.string "label"
    t.json "options"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["form_id", "position"], name: "index_fields_on_form_id_and_position"
    t.index ["form_id"], name: "index_fields_on_form_id"
  end

  create_table "forms", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "responses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "form_id", null: false
    t.datetime "updated_at", null: false
    t.index ["form_id"], name: "index_responses_on_form_id"
  end

  add_foreign_key "answers", "fields"
  add_foreign_key "answers", "responses"
  add_foreign_key "fields", "forms"
  add_foreign_key "responses", "forms"
end
