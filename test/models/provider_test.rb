require "test_helper"

class ProviderTest < ActiveSupport::TestCase
  test "es inválido sin nombre" do
    assert_not Provider.new(name: nil).valid?
    assert Provider.new(name: "Distribuidora").valid?
  end

  test "tiene muchos productos" do
    provider = Provider.create!(name: "Distribuidora Alfa")
    product = provider.products.create!(name: "Café", price: 1000, stock: 5)

    assert_equal [ product ], provider.products.reload
  end
end
