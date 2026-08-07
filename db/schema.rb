# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_07_170050) do
  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "line_total"
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.integer "quantity"
    t.integer "unit_price"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "store_id", null: false
    t.integer "total"
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_orders_on_store_id"
  end

  create_table "products", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "price"
    t.integer "provider_id", null: false
    t.integer "stock"
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_products_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "stores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "suborder_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "line_total"
    t.integer "product_id", null: false
    t.integer "quantity"
    t.integer "suborder_id", null: false
    t.integer "unit_price"
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_suborder_items_on_product_id"
    t.index ["suborder_id"], name: "index_suborder_items_on_suborder_id"
  end

  create_table "suborders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "provider_id", null: false
    t.integer "subtotal"
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_suborders_on_order_id"
    t.index ["provider_id"], name: "index_suborders_on_provider_id"
  end

  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "stores"
  add_foreign_key "products", "providers"
  add_foreign_key "suborder_items", "products"
  add_foreign_key "suborder_items", "suborders"
  add_foreign_key "suborders", "orders"
  add_foreign_key "suborders", "providers"
end
