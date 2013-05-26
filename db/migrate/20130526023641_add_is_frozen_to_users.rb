class AddIsFrozenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :is_frozen, :boolean, default: false
  end
  def down
    remove_column :users, :is_frozen
  end
end
