require "test_helper"

class OrderItemTest < ActiveSupport::TestCase
  def setup
    @store = Store.create!(name: "Tienda Demo")
    @provider = Provider.create!(name: "Proveedor A")
    @product = Product.create!(provider: @provider, name: "P", price_cents: 100, stock: 5)
    @order = Order.create!(store: @store, total_cents: 0)
  end

  test "validaciones de cantidad" do
    item = @order.order_items.build(product: @product, quantity: 0, unit_price_cents: 100, line_total_cents: 0)

    assert_not item.valid?
    assert item.errors[:quantity].any?
  end

  test "line_total debe ser unit_price x quantity" do
    item = @order.order_items.build(product: @product, quantity: 3, unit_price_cents: 100, line_total_cents: 999)

    assert_not item.valid?
    assert item.errors[:line_total_cents].any?
  end
end
