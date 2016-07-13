class AddRCountToKeywordCounts < ActiveRecord::Migration
  def change
  	add_column :keyword_counts, :r_count, :integer  	
  end
end
