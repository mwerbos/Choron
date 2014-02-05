class CreateSchema < ActiveRecord::Migration
  def change
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
      t.integer  "cut"
      t.string   "type"
    end

    create_table "bounties", :force => true do |t|
      t.integer  "user_id"
      t.integer  "chore_id"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    create_table "chore_schedulers", :force => true do |t|
      t.text     "default_bids"
      t.integer  "respawn_time"
      t.datetime "created_at",   :null => false
      t.datetime "updated_at",   :null => false
      t.integer  "chore_id"
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
      t.string   "type"
      t.datetime "start_date"
      t.text     "contributions"
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
      t.string   "queue"
    end

    create_table "sessions", :force => true do |t|
      t.string   "session_id", :null => false
      t.text     "data"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

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
      t.datetime "created_at",                           :null => false
      t.datetime "updated_at",                           :null => false
      t.integer  "chorons"
      t.string   "bid_prefs"
      t.boolean  "is_frozen",         :default => false
    end

    create_table "versions", :force => true do |t|
      t.string   "item_type",  :null => false
      t.integer  "item_id",    :null => false
      t.string   "event",      :null => false
      t.string   "whodunnit"
      t.text     "object"
      t.datetime "created_at"
    end

    add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  end
end
