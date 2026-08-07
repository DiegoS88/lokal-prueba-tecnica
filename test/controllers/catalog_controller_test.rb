require "test_helper"

class CatalogControllerTest < ActionDispatch::IntegrationTest
  def setup
    @store = Store.create!(name: "Tienda Demo")
    @currency = Currency.create!(code: "CLP", precision: 3, name: "Peso Chileno")
    @provider_a = Provider.create!(name: "Proveedor A")
    @provider_b = Provider.create!(name: "Proveedor B")
    @prod_a = Product.create!(provider: @provider_a, name: "Café A", price: 1000, stock: 5)
    @prod_b = Product.create!(provider: @provider_b, name: "Arroz B", price: 2000, stock: 3)
    @prod_sin_stock = Product.create!(provider: @provider_b, name: "Agotado", price: 500, stock: 0)
  end

  test "index muestra solo productos con stock disponible" do
    get root_path
    assert_response :success
    assert_match @prod_a.name, response.body
    assert_match @prod_b.name, response.body
    assert_no_match @prod_sin_stock.name, response.body
  end

  test "index filtra por proveedor" do
    get root_path(provider_id: @provider_a.id)
    assert_response :success
    assert_match @prod_a.name, response.body
    assert_no_match @prod_b.name, response.body
    assert_no_match @prod_sin_stock.name, response.body
  end

  test "un provider_id inexistente se ignora y muestra todo el catálogo" do
    get root_path(provider_id: 999_999)
    assert_response :success
    assert_match @prod_a.name, response.body
    assert_match @prod_b.name, response.body
  end
end
