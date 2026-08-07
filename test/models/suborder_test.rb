require "test_helper"

class SuborderTest < ActiveSupport::TestCase
  def setup
    @provider_a = Provider.create!(name: "Proveedor A")
    @provider_b = Provider.create!(name: "Proveedor B")
    @product_a = Product.create!(provider: @provider_a, name: "A", price_cents: 100, stock: 5)
    @product_b = Product.create!(provider: @provider_b, name: "B", price_cents: 200, stock: 5)
    @store = Store.create!(name: "Tienda Demo")
    @order = Order.create!(store: @store, total_cents: 0)
  end

  test "no permite items de proveedores distintos en la misma suborden" do
    suborder = @order.suborders.build(provider: @provider_a, subtotal_cents: 300)
    suborder.suborder_items.build(product: @product_a, quantity: 1, unit_price_cents: 100, line_total_cents: 100)
    suborder.suborder_items.build(product: @product_b, quantity: 1, unit_price_cents: 200, line_total_cents: 200)

    assert_not suborder.valid?
    assert suborder.errors[:base].any?
  end

  test "valida subtotal no negativo" do
    suborder = @order.suborders.build(provider: @provider_a, subtotal_cents: -5)

    assert_not suborder.valid?
  end
end
