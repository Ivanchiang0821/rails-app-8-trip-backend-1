class CreateApiCounts < ActiveRecord::Migration
  def change
    create_table :api_counts do |t|
      t.integer :cnt0, default: 0
      t.integer :cnt1, default: 0
      t.integer :cnt2, default: 0
      t.integer :cnt3, default: 0

      t.timestamps null: false
    end
  end
end
