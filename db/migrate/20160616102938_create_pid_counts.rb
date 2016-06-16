class CreatePidCounts < ActiveRecord::Migration
  def change
    create_table :pid_counts do |t|
      t.string :pid
      t.string :option
      t.integer :count

      t.timestamps null: false
    end
  end
end
