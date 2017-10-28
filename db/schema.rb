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

ActiveRecord::Schema.define(version: 20171028190751) do

  create_table "chat_messages", force: :cascade do |t|
    t.string   "message"
    t.integer  "group_id"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "global_scope", default: false
  end

  create_table "direct_messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "from_user_id"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "seen",         default: false
  end

  create_table "followed_groups", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "member_group_petitions", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "approved",   default: false
    t.string   "note",       default: "Please add me to this buying group"
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
  end

  create_table "member_groups", force: :cascade do |t|
    t.integer  "member_id"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "sdcc_member_id"
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.boolean  "covered"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "active",          default: false
    t.string   "last_name"
    t.boolean  "wensday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.boolean  "in_progress"
    t.integer  "sponsor_id"
    t.text     "payment_info"
    t.date     "checked_in_date"
  end

  create_table "needs", force: :cascade do |t|
    t.boolean  "wensday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.boolean  "covered"
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "purchases", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "need_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "member_id"
    t.integer  "confirmation_code"
    t.integer  "covering_id"
    t.float    "price"
    t.text     "notes"
    t.boolean  "wensday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.boolean  "in_progress"
  end

  create_table "temps", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password"
    t.string   "val_code"
    t.string   "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "avatar_url"
    t.string   "validation_code"
    t.boolean  "is_admin",               default: false
    t.text     "payment_info"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "validation_codes", force: :cascade do |t|
    t.string   "email"
    t.string   "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
