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

ActiveRecord::Schema.define(:version => 20110803080545) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "entries", :force => true do |t|
    t.integer  "party_id"
    t.integer  "sortie_id"
    t.string   "state",      :default => "waiting", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "party_type"
  end

  create_table "entry_actions", :force => true do |t|
    t.integer  "entry_id",   :null => false
    t.integer  "by_id",      :null => false
    t.string   "action",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follows", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "follows", ["followed_id"], :name => "index_follows_on_followed_id"
  add_index "follows", ["follower_id", "followed_id"], :name => "index_follows_on_follower_id_and_followed_id", :unique => true
  add_index "follows", ["follower_id"], :name => "index_follows_on_follower_id"

  create_table "friendships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "recipient_email"
    t.string   "token",           :null => false
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "picture_ratings", :force => true do |t|
    t.integer  "user_id"
    t.string   "picture_file_name"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sortie_report_id"
  end

  create_table "place_reviews", :force => true do |t|
    t.integer  "place_id"
    t.integer  "score"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sortie_report_id"
  end

  create_table "place_yelps", :force => true do |t|
    t.integer  "place_id"
    t.string   "url"
    t.integer  "review_count"
    t.string   "rating_img_url_small"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", :force => true do |t|
    t.string   "kind"
    t.float    "lat",           :null => false
    t.float    "lng",           :null => false
    t.string   "provider"
    t.string   "provider_id"
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state_code"
    t.string   "postal_code"
    t.string   "country_code"
    t.string   "cross_streets"
    t.string   "neighborhoods"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "site_reviews", :force => true do |t|
    t.integer  "score"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sortie_report_id"
  end

  create_table "sortie_reports", :force => true do |t|
    t.integer  "sortie_id",           :null => false
    t.integer  "by_id",               :null => false
    t.boolean  "at_location"
    t.string   "cancellation_notice"
    t.integer  "late_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sortie_reports_culprits", :id => false, :force => true do |t|
    t.integer "sortie_report_id"
    t.integer "user_id"
  end

  create_table "sortie_updates", :force => true do |t|
    t.integer  "sortie_id",  :null => false
    t.integer  "by_id",      :null => false
    t.string   "kind",       :null => false
    t.integer  "late_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sorties", :force => true do |t|
    t.integer  "size",        :default => 2, :null => false
    t.string   "state",                      :null => false
    t.integer  "host_id",                    :null => false
    t.integer  "guest_id"
    t.string   "category"
    t.datetime "time"
    t.integer  "place_id"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "host_type"
    t.string   "guest_type"
  end

  create_table "user_ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sortie_report_id"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "state",             :default => "active", :null => false
    t.string   "level",             :default => "user",   :null => false
    t.string   "email"
    t.string   "cellphone"
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
    t.boolean  "filter_age",        :default => false,    :null => false
    t.boolean  "filter_height",     :default => false,    :null => false
    t.string   "picture"
    t.string   "perishable_token"
    t.integer  "invitation_id"
    t.integer  "invitations_left"
    t.boolean  "show_foodia",       :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["perishable_token"], :name => "index_users_on_perishable_token"

  create_table "wings", :force => true do |t|
    t.integer  "lead_id"
    t.integer  "mate_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
