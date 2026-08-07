class CreateDiscounts < ActiveRecord::Migration[8.1]
  def change
    create_table :discounts do |t|
      t.references :product, null: false, foreign_key: true
      t.decimal :value, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end
  end
end
