class AddCutToBid < ActiveRecord::Migration
  def change
    add_column :bids, :cut, :integer
  end
end
