# encoding: UTF-8
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

<<<<<<< HEAD
ActiveRecord::Schema.define(:version => 20120910012851) do
=======
ActiveRecord::Schema.define(:version => 20120914150419) do
>>>>>>> b3d4f5a969903af83e367da3da6ac9f22f2f68b2

  create_table "auctions", :force => true do |t|
    t.datetime "expiration_date"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "chore_id"
  end

  create_table "bids", :force => true do |t|
    t.integer  "amount"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "user_id"
    t.integer  "auction_id"
  end

<<<<<<< HEAD
  create_table "chore_schedulers", :force => true do |t|
    t.text     "default_bids"
    t.integer  "respawn_time"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "chore_id"
=======
  create_table "bounties", :force => true do |t|
    t.integer  "user_id"
    t.integer  "chore_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
>>>>>>> b3d4f5a969903af83e367da3da6ac9f22f2f68b2
  end

  create_table "chores", :force => true do |t|
    t.string   "name"
    t.datetime "due_date"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "user_id"
    t.integer  "auctions_count"
    t.integer  "value"
    t.boolean  "done",           :default => false
    t.integer  "bounties_count", :default => 0,     :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "settings", :force => true do |t|
    t.string   "var",                      :null => false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", :limit => 30
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "settings", ["thing_type", "thing_id", "var"], :name => "index_settings_on_thing_type_and_thing_id_and_var", :unique => true

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "chorons"
    t.string   "bid_prefs"
  end

end
