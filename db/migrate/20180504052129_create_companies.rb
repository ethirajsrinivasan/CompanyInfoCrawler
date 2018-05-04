class CreateCompanies < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :home_page
      t.boolean :verified

      t.timestamps
    end
  end
end
