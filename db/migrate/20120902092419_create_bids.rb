class CreateBids < ActiveRecord::Migration
  def change
    drop_table :bids
    create_table :bids do |t|
      t.integer :amount

      t.timestamps
    end
    add_column :bids, :user_id, :integer
    add_column :bids, :auction_id, :integer
  end
end
