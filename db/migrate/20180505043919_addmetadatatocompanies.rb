class Addmetadatatocompanies < ActiveRecord::Migration[5.1]
  def change
  	add_column :companies, :metadata, :jsonb, null: false, default: '{}'
  end
end
