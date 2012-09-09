class AddValueToChores < ActiveRecord::Migration
  def change
    add_column :chores, :value, :integer
  end
end
