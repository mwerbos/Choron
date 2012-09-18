class AddBidPrefsToUser < ActiveRecord::Migration
  def change
    add_column :users, :bid_prefs, :string
  end
end
