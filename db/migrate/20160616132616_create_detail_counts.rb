class CreateDetailCounts < ActiveRecord::Migration
  def change
    create_table :detail_counts do |t|
      t.string :pid
      t.string :name
      t.integer :count

      t.timestamps null: false
    end
  end
end
