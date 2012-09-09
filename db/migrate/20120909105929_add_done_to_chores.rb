class AddDoneToChores < ActiveRecord::Migration
  def change
    add_column :chores, :done, :boolean, default:false 
  end
end
