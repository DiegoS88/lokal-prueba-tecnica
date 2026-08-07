class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :provider, null: false, foreign_key: true
      t.string :name
      t.integer :price_cents
      t.integer :stock

      t.timestamps
    end
  end
end
