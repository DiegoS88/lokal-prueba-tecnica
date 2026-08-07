require "test_helper"

class SuborderItemTest < ActiveSupport::TestCase
  def setup
    @provider = Provider.create!(name: "Distribuidora Alfa")
    @product = Product.create!(provider: @provider, name: "Café", price: 100, stock: 5)
    @store = Store.create!(name: "Tienda Demo")
    @order = Order.create!(store: @store, total: 0)
    @suborder = @order.suborders.create!(provider: @provider, subtotal: 0)
  end

  test "valida cantidad mayor que cero" do
    item = @suborder.suborder_items.build(product: @product, quantity: 0, unit_price: 100, line_total: 0)

    assert_not item.valid?
    assert item.errors[:quantity].any?
  end

  test "valida montos no negativos" do
    item = @suborder.suborder_items.build(product: @product, quantity: 1, unit_price: -100, line_total: -100)

    assert_not item.valid?
    assert item.errors[:unit_price].any?
    assert item.errors[:line_total].any?
  end

  test "line_total debe ser unit_price x quantity" do
    item = @suborder.suborder_items.build(product: @product, quantity: 2, unit_price: 100, line_total: 500)

    assert_not item.valid?
    assert item.errors[:line_total].any?
  end
end
