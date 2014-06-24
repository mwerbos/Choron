class AddChoreSchedulerReferenceToChore < ActiveRecord::Migration
  def change
    add_reference :chores, :chore_scheduler, index: true
  end
end
