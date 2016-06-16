class CreateKeywordCounts < ActiveRecord::Migration
  def change
    create_table :keyword_counts do |t|
      t.string :keyword
      t.integer :count, default: 0
      t.boolean :autocomplete

      t.timestamps null: false
    end
  end
end
