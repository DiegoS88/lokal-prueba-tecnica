require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def setup
    @store = Store.create!(name: "Tienda Demo")
    @currency = Currency.create!(code: "CLP", precision: 3, name: "Peso Chileno")
  end

  test "valida total presente y no negativo" do
    assert_not Order.new(store: @store, total: nil).valid?
    assert_not Order.new(store: @store, total: -1).valid?
    assert Order.new(store: @store, total: 0).valid?
  end

  test "total_in_currency divide por el divisor de la moneda" do
    order = Order.create!(store: @store, total: 2000)

    assert_equal 2, order.total_in_currency
  end
end
