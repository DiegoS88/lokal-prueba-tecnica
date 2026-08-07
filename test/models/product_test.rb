require "test_helper"

class ProductTest < ActiveSupport::TestCase
  def setup
    @provider = Provider.create!(name: "Distribuidora Alfa")
    @currency = Currency.create!(code: "CLP", precision: 3, name: "Peso Chileno")
  end

  test "valida presencia de name, price y stock" do
    product = Product.new(provider: @provider, name: nil, price: nil, stock: nil)

    assert_not product.valid?
    %i[name price stock].each { |attr| assert product.errors[attr].any?, "debería validar #{attr}" }
  end

  test "no permite precios o stock negativos" do
    assert_not Product.new(provider: @provider, name: "A", price: -1, stock: 0).valid?
    assert_not Product.new(provider: @provider, name: "A", price: 0, stock: -1).valid?
  end

  test "scope available excluye productos sin stock" do
    @provider.products.create!(name: "Agotado", price: 100, stock: 0)
    product = @provider.products.create!(name: "Disponible", price: 100, stock: 1)

    assert_includes Product.available, product
    assert_not_includes Product.available, Product.find_by(name: "Agotado")
  end

  test "can_supply? acepta cantidades dentro del stock y rechaza las demás" do
    product = @provider.products.create!(name: "A", price: 100, stock: 3)

    assert product.can_supply?(0)
    assert product.can_supply?(3)
    assert_not product.can_supply?(4)
    assert_not product.can_supply?(-1)
  end

  test "price_in_currency divide por el divisor de la moneda" do
    product = @provider.products.create!(name: "A", price: 2500, stock: 3)

    assert_equal 2, product.price_in_currency
  end
end
