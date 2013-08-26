class AddContributionsToChore < ActiveRecord::Migration
  def change
    add_column :chores, :contributions, :text
  end
end
