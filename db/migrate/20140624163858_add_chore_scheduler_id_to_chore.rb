class AddChoreSchedulerIdToChore < ActiveRecord::Migration
  def change
    add_column :chores, :chore_scheduler_id, :integer
  end
end
