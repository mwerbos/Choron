class AddTypeToChore < ActiveRecord::Migration
  def change
    add_column :chores, :type, :string
  end
end
