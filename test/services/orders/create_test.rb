require "test_helper"

class Orders::CreateTest < ActiveSupport::TestCase
  def setup
    @store = Store.create!(name: "Tienda Demo")
    @provider_a = Provider.create!(name: "Proveedor A")
    @provider_b = Provider.create!(name: "Proveedor B")
    @prod_a1 = Product.create!(provider: @provider_a, name: "A1", price_cents: 1000, stock: 10)
    @prod_b1 = Product.create!(provider: @provider_b, name: "B1", price_cents: 2000, stock: 5)
    @prod_b2 = Product.create!(provider: @provider_b, name: "B2", price_cents: 500, stock: 3)
  end

  test "crea una suborden por proveedor con sus totals" do
    service = Orders::Create.new(store: @store,
                                 lines: { @prod_a1.id => 2, @prod_b1.id => 1, @prod_b2.id => 3 })
    order = service.call

    assert order.present?, "la orden debería crearse"
    assert_equal 2, order.suborders.count
    assert_equal [ @provider_a.id, @provider_b.id ].sort, order.suborders.map(&:provider_id).sort

    sub_a = order.suborders.find_by(provider: @provider_a)
    sub_b = order.suborders.find_by(provider: @provider_b)

    assert_equal @prod_a1.price_cents * 2, sub_a.subtotal_cents
    assert_equal @prod_b1.price_cents + @prod_b2.price_cents * 3, sub_b.subtotal_cents

    expected_total = @prod_a1.price_cents * 2 + @prod_b1.price_cents + @prod_b2.price_cents * 3
    assert_equal expected_total, order.total_cents
  end

  test "el item conserva el precio del momento de la compra aunque luego cambie" do
    order = Orders::Create.new(store: @store, lines: { @prod_a1.id => 1 }).call
    item = order.order_items.find_by(product: @prod_a1)

    @prod_a1.update!(price_cents: 9999) # cambia luego de comprar

    assert_equal 1000, item.reload.unit_price_cents
    assert_equal 1000, item.line_total_cents
  end

  test "ante stock insuficiente falla sin dejar registros a medio crear" do
    before_order = Order.count
    before_sub = Suborder.count
    before_item = OrderItem.count
    service = Orders::Create.new(store: @store, lines: { @prod_a1.id => 2, @prod_b1.id => 99 })

    order = service.call

    assert_nil order
    assert service.errors.any?
    assert_match(/Stock insuficiente/, service.errors.join(" "))
    assert_equal before_order, Order.count, "no deben quedar ordenes parcialmente creadas"
    assert_equal before_sub, Suborder.count
    assert_equal before_item, OrderItem.count
    assert_equal 10, @prod_a1.reload.stock
    assert_equal 5, @prod_b1.reload.stock
  end

  test "descuenta stock al completar la compra" do
    Orders::Create.new(store: @store, lines: { @prod_a1.id => 4 }).call

    assert_equal 6, @prod_a1.reload.stock
  end

  test "carrito vacio no crea orden" do
    service = Orders::Create.new(store: @store, lines: {})

    assert_nil service.call
    assert service.errors.any?
  end

  test "cantidades no positivas se ignoran" do
    order = Orders::Create.new(store: @store, lines: { @prod_a1.id => 0, @prod_b1.id => -3 }).call

    assert_nil order
  end
end
