class AddDebugToKeywordCounts < ActiveRecord::Migration
  def change
  	add_column :keyword_counts, :debug, :integer
  end
end
