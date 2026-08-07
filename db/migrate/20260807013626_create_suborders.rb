class CreateSuborders < ActiveRecord::Migration[8.1]
  def change
    create_table :suborders do |t|
      t.references :order, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true
      t.integer :subtotal_cents

      t.timestamps
    end
  end
end
