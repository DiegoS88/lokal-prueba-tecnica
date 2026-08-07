class AddMinPurchaseToProviders < ActiveRecord::Migration[8.1]
  def change
    add_column :providers, :min_purchase, :decimal, null: false, default: 0
  end
end
