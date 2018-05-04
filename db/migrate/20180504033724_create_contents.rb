class CreateContents < ActiveRecord::Migration[5.1]
  def change
    create_table :contents do |t|
      t.integer :company_id
      t.string :url
      t.string :tag
      t.text :data
      t.timestamps
    end
  end
end
