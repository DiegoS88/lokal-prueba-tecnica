require "test_helper"

class StoreTest < ActiveSupport::TestCase
  test "es inválido sin nombre" do
    store = Store.new(name: nil)

    assert_not store.valid?
    assert store.errors[:name].any?
  end

  test "tiene muchas órdenes" do
    store = Store.create!(name: "Tienda Demo")
    order = store.orders.create!(total: 100)

    assert_equal [ order ], store.orders.reload
  end
end
