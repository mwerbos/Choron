class CreateAuctions < ActiveRecord::Migration
  def up
    create_table :auctions do |t|
      t.datetime :expiration_date
      t.timestamps
      t.integer  :chore_id
    end
  end
  def down
    drop_table :auctions
  end
end

class CreateBids < ActiveRecord::Migration
  def up
    create_table :bids do |t|
      t.integer  :amount
      t.timestamps
      t.integer  :user_id
      t.integer  :auction_id
    end
  end
  def down
    drop_table :bids
  end
end
  
class CreateChores < ActiveRecord::Migration
  def up
    create_table :chores do |t|
      t.string   :name
      t.datetime :due_date
      t.timestamps
      t.integer  :user_id
    end
  end
  def down
    drop_table :chores
  end
end

class CreateUsers < ActiveRecord::Migration
  def up
    create_table :users do |t|
      t.string   :username
      t.string   :email
      t.string   :crypted_password
      t.string   :password_salt
      t.string   :persistence_token
      t.timestamps
    end
  end
end
