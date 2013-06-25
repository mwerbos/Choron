class AddStartDateToChore < ActiveRecord::Migration
  def change
    add_column :chores, :start_date, :datetime
  end
end
