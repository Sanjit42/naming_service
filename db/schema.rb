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

ActiveRecord::Schema.define(version: 20180314101935) do

  create_table "dropbox_info", force: :cascade do |t|
    t.integer "intern_id"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["intern_id"], name: "index_dropbox_info_on_intern_id"
  end

  create_table "emails", force: :cascade do |t|
    t.integer "intern_id"
    t.string "category"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["intern_id"], name: "index_emails_on_intern_id"
  end

  create_table "github_info", force: :cascade do |t|
    t.integer "intern_id"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["intern_id"], name: "index_github_info_on_intern_id"
  end

  create_table "interns", force: :cascade do |t|
    t.string "display_name"
    t.string "first_name"
    t.string "last_name"
    t.integer "batch"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "emp_id"
    t.date "dob"
    t.string "gender"
    t.string "phone_number"
  end

  create_table "slack_info", force: :cascade do |t|
    t.integer "intern_id"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["intern_id"], name: "index_slack_info_on_intern_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
