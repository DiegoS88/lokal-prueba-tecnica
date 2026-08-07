class RenamePriceCentsColumns < ActiveRecord::Migration[8.1]
  def change
    rename_column :products, :price_cents, :price
    rename_column :order_items, :unit_price_cents, :unit_price
    rename_column :order_items, :line_total_cents, :line_total
    rename_column :suborder_items, :unit_price_cents, :unit_price
    rename_column :suborder_items, :line_total_cents, :line_total
    rename_column :suborders, :subtotal_cents, :subtotal
    rename_column :orders, :total_cents, :total
  end
end
