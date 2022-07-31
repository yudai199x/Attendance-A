# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20220726070320) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.datetime "scheduled_at"
    t.string "worked_contents"
    t.string "confirmed_request"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "overwork_next_day"
    t.string "overwork_status"
    t.boolean "overwork_chk"
    t.boolean "chg_chk"
    t.boolean "aprv_chk"
    t.boolean "chg_next_day"
    t.string "chg_confirmed"
    t.string "chg_status"
    t.datetime "b4_started_at"
    t.datetime "b4_finished_at"
    t.string "aprv_status"
    t.string "aprv_confirmed"
    t.date "aprv_day"
    t.datetime "af_started_at"
    t.datetime "af_finished_at"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "hubs", force: :cascade do |t|
    t.integer "number"
    t.string "name"
    t.string "worked_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "affiliation"
    t.integer "employee_number"
    t.integer "uid"
    t.datetime "basic_work_time", default: "2022-07-23 23:00:00"
    t.datetime "designated_work_start_time", default: "2022-07-24 00:00:00"
    t.datetime "designated_work_end_time", default: "2022-07-24 09:00:00"
    t.boolean "superior", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_number"], name: "index_users_on_employee_number", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

end
