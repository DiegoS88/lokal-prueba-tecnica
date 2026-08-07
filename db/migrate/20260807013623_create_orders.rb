class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :store, null: false, foreign_key: true
      t.integer :total_cents

      t.timestamps
    end
  end
end
