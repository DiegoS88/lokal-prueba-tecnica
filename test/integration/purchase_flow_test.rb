require "test_helper"

class PurchaseFlowTest < ActionDispatch::IntegrationTest
  def setup
    @store = Store.create!(name: "Tienda Demo")
    @currency = Currency.create!(code: "CLP", precision: 3, name: "Peso Chileno")
    @provider_a = Provider.create!(name: "Proveedor A")
    @provider_b = Provider.create!(name: "Proveedor B")
    @prod_a1 = Product.create!(provider: @provider_a, name: "A1", price: 1000, stock: 10)
    @prod_a2 = Product.create!(provider: @provider_a, name: "A2", price: 700, stock: 4)
    @prod_b1 = Product.create!(provider: @provider_b, name: "B1", price: 2000, stock: 5)
  end

  test "el catalogo muestra todos los productos" do
    get root_path
    assert_response :success
    assert_match(@prod_a1.name, response.body)
    assert_match(@prod_b1.name, response.body)
  end

  test "el filtro por proveedor solo muestra sus productos" do
    get root_path(provider_id: @provider_a.id)
    assert_response :success
    assert_match(@prod_a1.name, response.body)
    assert_match(@prod_a2.name, response.body)
    assert_no_match(@prod_b1.name, response.body)
  end

  test "un provider_id inexistente se ignora y muestra todo el catalogo" do
    get root_path(provider_id: 999_999)
    assert_response :success
    assert_match(@prod_a1.name, response.body)
    assert_match(@prod_b1.name, response.body)
  end

  test "flujo completo: agrego, actualizo, elimino y confirmo" do
    get cart_path
    assert_response :success
    assert_match(/carrito está vacío/i, response.body)

    # Agregar productos de dos proveedores
    post cart_add_path, params: { product_id: @prod_a1.id, quantity: 2 }, headers: { "HTTP_REFERER" => root_path }
    post cart_add_path, params: { product_id: @prod_a1.id, quantity: 1 }, headers: { "HTTP_REFERER" => root_path }
    post cart_add_path, params: { product_id: @prod_b1.id, quantity: 3 }, headers: { "HTTP_REFERER" => root_path }

    get cart_path
    assert_match(@prod_a1.name, response.body)
    assert_match(@prod_b1.name, response.body)

    # Actualizar cantidad
    post cart_update_path, params: { product_id: @prod_a1.id, quantity: 2 }
    follow_redirect!

    # Eliminar un producto
    delete cart_remove_path(product_id: @prod_b1.id)
    follow_redirect!
    assert_match(/Producto eliminado/, response.body)

    # Confirmar compra
    assert_difference "Order.count", 1 do
      post orders_path
    end
    assert_response :redirect
    follow_redirect!

    order = Order.last
    assert_equal 1, order.suborders.count
    assert_equal [ @provider_a.id ], order.suborders.map(&:provider_id)
    assert_equal @prod_a1.price * 2, order.total
  end

  test "confirmar con stock insuficiente muestra error y no crea orden" do
    post cart_add_path, params: { product_id: @prod_a2.id, quantity: 5 }, headers: { "HTTP_REFERER" => root_path } # stock max 4
    assert_response :redirect
    follow_redirect!
    assert_match(/stock/i, response.body)

    assert_no_difference "Order.count" do
      post orders_path
    end
  end

  test "actualizar a cantidad invalida muestra error" do
    post cart_add_path, params: { product_id: @prod_a1.id, quantity: 1 }, headers: { "HTTP_REFERER" => root_path }
    post cart_update_path, params: { product_id: @prod_a1.id, quantity: 0 }, headers: { "HTTP_REFERER" => root_path }
    assert_response :redirect
    follow_redirect!
    assert_match(/mayor que cero/i, response.body)
  end
end
