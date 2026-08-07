require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @store = Store.create!(name: "Tienda Demo")
    @currency = Currency.create!(code: "CLP", precision: 3, name: "Peso Chileno")
    @provider = Provider.create!(name: "Proveedor A")
    @product = Product.create!(provider: @provider, name: "Café", price: 1000, stock: 5)
  end

  test "index lista las órdenes de la tienda actual" do
    order = Orders::Create.new(store: @store, lines: { @product.id => 2 }).call

    get orders_path
    assert_response :success
    assert_match /Mis Órdenes/, response.body
    assert_match "Tienda Demo", response.body
    assert_match order.id.to_s, response.body
  end

  test "index muestra un mensaje cuando no hay órdenes" do
    get orders_path
    assert_response :success
    assert_match(/no hay órdenes/i, response.body)
  end

  test "show renderiza el detalle de la orden con sus items" do
    order = Orders::Create.new(store: @store, lines: { @product.id => 2 }).call

    get order_path(order)
    assert_response :success
    assert_match "Orden ##{order.id}", response.body
    assert_match @product.name, response.body
    assert_match @provider.name, response.body
  end

  test "create confirma la compra, limpia el carrito y redirige a la orden" do
    post cart_add_path, params: { product_id: @product.id, quantity: 2 }, headers: { "HTTP_REFERER" => root_path }

    assert_difference "Order.count", 1 do
      post orders_path
    end
    assert_response :redirect
    assert_redirected_to order_path(Order.last)

    follow_redirect!
    get cart_path
    assert_match(/carrito está vacío/i, response.body)
  end

  test "create con carrito vacío no crea orden y muestra error" do
    assert_no_difference "Order.count" do
      post orders_path
    end
    assert_response :redirect
    assert_redirected_to cart_path
    follow_redirect!
    assert_match(/carrito está vacío/i, response.body)
  end

  test "create con stock insuficiente en el carrito no crea orden" do
    post cart_add_path, params: { product_id: @product.id, quantity: 3 }, headers: { "HTTP_REFERER" => root_path }
    @product.update!(stock: 2) # el stock baja entre el agregado y la confirmación

    assert_no_difference "Order.count" do
      post orders_path
    end
    assert_redirected_to cart_path
    follow_redirect!
    assert_match(/stock/i, response.body)
  end
end
