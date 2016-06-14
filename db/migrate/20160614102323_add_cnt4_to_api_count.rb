class AddCnt4ToApiCount < ActiveRecord::Migration
  def change
  	add_column :api_counts, :cnt4, :integer, default: 0
  end
end
