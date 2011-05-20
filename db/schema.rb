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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110508235629) do

  create_table "activities", :force => true do |t|
    t.string   "activity_type"
    t.string   "title"
    t.text     "description"
    t.datetime "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",          :default => "open"
    t.integer  "creator_duo_id"
    t.integer  "invitee_duo_id"
    t.float    "lat"
    t.float    "lng"
  end

  create_table "duos", :force => true do |t|
    t.integer  "host_id"
    t.integer  "participant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "cellphone"
    t.string   "picture_url"
    t.string   "sex"
    t.string   "sex_preference"
    t.date     "dob"
    t.integer  "min_age"
    t.integer  "max_age"
    t.integer  "height"
    t.integer  "min_height"
    t.integer  "max_height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.boolean  "filter_age",        :default => false,      :null => false
    t.boolean  "filter_height",     :default => false,      :null => false
    t.string   "completeness",      :default => "complete", :null => false
  end

  create_table "users_buddies", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.integer  "buddy_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "waitlist_entries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.string   "state",       :default => "waiting"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
