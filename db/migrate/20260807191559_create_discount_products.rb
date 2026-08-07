class CreateDiscountProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :discount_products do |t|
      t.references :discount, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end

    add_index :discount_products, [:discount_id, :product_id], unique: true
  end
end