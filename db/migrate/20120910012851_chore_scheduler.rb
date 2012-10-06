class ChoreScheduler < ActiveRecord::Migration
  def self.up
    create_table :chore_schedulers do |t| 
      t.text :default_bids
      t.integer :respawn_time
      t.timestamps
      t.integer :chore_id 
    end 
  end
  def self.down 
      drop_table :chore_schedulers
  end
end
