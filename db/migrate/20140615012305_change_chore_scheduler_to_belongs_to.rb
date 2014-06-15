class ChangeChoreSchedulerToBelongsTo < ActiveRecord::Migration
  def change
    add_column :chores, :chore_scheduler, :belongs_to
  end
end
