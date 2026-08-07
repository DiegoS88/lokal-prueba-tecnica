require "test_helper"

class CartControllerTest < ActionDispatch::IntegrationTest
  def setup
    @store = Store.create!(name: "Tienda Demo")
    @currency = Currency.create!(code: "CLP", precision: 3, name: "Peso Chileno")
    @provider = Provider.create!(name: "Proveedor A")
    @product = Product.create!(provider: @provider, name: "Café", price: 1000, stock: 3)
    @product_sin_stock = Product.create!(provider: @provider, name: "Agotado", price: 500, stock: 0)
  end

  test "show muestra el carrito vacío" do
    get cart_path
    assert_response :success
    assert_match(/carrito está vacío/i, response.body)
  end

  test "agregar un producto lo añade al carrito" do
    post cart_add_path, params: { product_id: @product.id, quantity: 2 }, headers: { "HTTP_REFERER" => root_path }

    get cart_path
    assert_match @product.name, response.body
    assert_match(/value="2"/, response.body)
  end

  test "agregar acumula cantidad si el producto ya está en el carrito" do
    post cart_add_path, params: { product_id: @product.id, quantity: 1 }, headers: { "HTTP_REFERER" => root_path }
    post cart_add_path, params: { product_id: @product.id, quantity: 2 }, headers: { "HTTP_REFERER" => root_path }

    get cart_path
    assert_match(/value="3"/, response.body)
  end

  test "agregar cantidad menor o igual a cero muestra error y no agrega" do
    post cart_add_path, params: { product_id: @product.id, quantity: 0 }, headers: { "HTTP_REFERER" => root_path }
    assert_response :redirect
    follow_redirect!
    assert_match(/mayor que cero/i, response.body)

    get cart_path
    assert_match(/carrito está vacío/i, response.body)
  end

  test "agregar por encima del stock muestra error y no agrega" do
    post cart_add_path, params: { product_id: @product.id, quantity: 4 }, headers: { "HTTP_REFERER" => root_path }
    assert_response :redirect
    follow_redirect!
    assert_match(/no hay suficiente stock/i, response.body)

    get cart_path
    assert_match(/carrito está vacío/i, response.body)
  end

  test "agregar un producto sin stock disponible muestra error" do
    post cart_add_path, params: { product_id: @product_sin_stock.id, quantity: 1 }, headers: { "HTTP_REFERER" => root_path }
    assert_response :redirect
    follow_redirect!
    assert_match(/no existe o no tiene stock/i, response.body)
  end

  test "agregar un producto inexistente muestra error" do
    post cart_add_path, params: { product_id: 999_999, quantity: 1 }, headers: { "HTTP_REFERER" => root_path }
    assert_response :redirect
    follow_redirect!
    assert_match(/no existe o no tiene stock/i, response.body)
  end

  test "actualizar cantidad persiste el nuevo valor" do
    post cart_add_path, params: { product_id: @product.id, quantity: 2 }, headers: { "HTTP_REFERER" => root_path }
    post cart_update_path, params: { product_id: @product.id, quantity: 3 }
    assert_response :redirect
    assert_redirected_to cart_path
    follow_redirect!
    assert_match(/actualizado/i, response.body)

    get cart_path
    assert_match(/value="3"/, response.body)
  end

  test "actualizar por encima del stock muestra error y mantiene el valor" do
    post cart_add_path, params: { product_id: @product.id, quantity: 2 }, headers: { "HTTP_REFERER" => root_path }
    post cart_update_path, params: { product_id: @product.id, quantity: 5 }
    follow_redirect!
    assert_match(/no hay suficiente stock/i, response.body)

    get cart_path
    assert_match(/value="2"/, response.body)
  end

  test "actualizar un producto que no está en el carrito muestra alerta" do
    post cart_update_path, params: { product_id: @product.id, quantity: 2 }
    assert_response :redirect
    follow_redirect!
    assert_match(/no está en el carrito/i, response.body)
  end

  test "eliminar un producto vacía el carrito" do
    post cart_add_path, params: { product_id: @product.id, quantity: 1 }, headers: { "HTTP_REFERER" => root_path }
    delete cart_remove_path(product_id: @product.id)
    assert_response :redirect
    follow_redirect!
    assert_match(/eliminado/i, response.body)

    get cart_path
    assert_match(/carrito está vacío/i, response.body)
  end
end
