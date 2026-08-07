class CreateCurrencies < ActiveRecord::Migration[8.1]
  def change
    create_table :currencies do |t|
      t.string :code, null: false
      t.integer :precision, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
