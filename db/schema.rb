# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2014_09_21_032348) do

  create_table "authentications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider", limit: 255, null: false
    t.string "uid", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "token", limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string "username", limit: 255, null: false
    t.string "email", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 255
    t.string "avatar_url", limit: 255
    t.boolean "subscribe", default: true
    t.string "activation_state", limit: 255
    t.string "activation_token", limit: 255
    t.datetime "activation_token_expires_at"
    t.string "crypted_password", limit: 255
    t.string "salt", limit: 255
    t.string "feed_token", limit: 255
    t.integer "daily_mail_hour", default: 9, null: false
    t.index ["activation_token"], name: "index_users_on_activation_token"
  end

end
