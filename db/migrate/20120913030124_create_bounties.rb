class CreateBounties < ActiveRecord::Migration
  def change
    create_table :bounties do |t|
      t.integer :user_id
      t.integer :chore_id

      t.timestamps
    end
  end
end
