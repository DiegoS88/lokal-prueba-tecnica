class RemoveProductFromDiscounts < ActiveRecord::Migration[8.1]
  def change
    remove_reference :discounts, :product, foreign_key: true
  end
end