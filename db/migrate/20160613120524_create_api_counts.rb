class CreateApiCounts < ActiveRecord::Migration
  def change
    create_table :api_counts do |t|
      t.integer :cnt_search_by_keyword, default: 0
      t.integer :cnt_search_by_pid, default: 0
      t.integer :cnt_search_by_coordinate, default: 0
      t.integer :cnt_get_next_page_pid, default: 0
      t.integer :cnt_get_next_page_keyword, default: 0      
      t.integer :cnt_get_pid, default: 0
      t.integer :cnt_get_detail, default: 0

      t.timestamps null: false
    end
  end
end
