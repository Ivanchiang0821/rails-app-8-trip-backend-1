class AddOptionToKeywordCount < ActiveRecord::Migration
  def change
  	add_column :keyword_counts, :option, :string
  end
end
