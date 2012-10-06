class AddBountiesCountToChores < ActiveRecord::Migration
  def self.up
    add_column :chores, :bounties_count, :integer, null:false, default: 0
  end
  def self.down
    remove_column :chores, :bounties_count
  end
end
