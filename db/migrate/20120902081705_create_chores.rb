class CreateChores < ActiveRecord::Migration
  def change
    #drop_table :chores
    create_table :chores do |t|
      t.string :name
      t.datetime :due_date

      t.timestamps
    end
    add_column :chores, :user_id, :integer
  end
end
