class CreateAuctions < ActiveRecord::Migration
  def change
    drop_table :auctions
    create_table :auctions do |t|
      t.datetime :expiration_date

      t.timestamps
    end
    add_column :auctions, :chore_id, :integer
  end
end
