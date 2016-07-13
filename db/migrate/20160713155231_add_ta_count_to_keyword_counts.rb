class AddTaCountToKeywordCounts < ActiveRecord::Migration
  def change
  	add_column :keyword_counts, :ta_count, :integer    	
  end
end
