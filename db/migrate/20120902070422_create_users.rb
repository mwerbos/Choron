class CreateUsers < ActiveRecord::Migration
  def change
    add_column :users, :chorons, :integer
  end
end
