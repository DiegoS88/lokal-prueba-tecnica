require "test_helper"

class DiscountTest < ActiveSupport::TestCase
  def setup
    @provider = Provider.create!(name: "Distribuidora Alfa")
    @product = @provider.products.create!(name: "Producto", price: 100, stock: 1)
  end

  def build_discount(attributes = {})
    Discount.new(
      { start_date: Date.today, end_date: Date.tomorrow }.merge(attributes)
    )
  end

  test "valida presencia de value, start_date y end_date" do
    discount = build_discount(value: nil, start_date: nil, end_date: nil)

    assert_not discount.valid?
    %i[value start_date end_date].each { |attr| assert discount.errors[attr].any?, "debería validar #{attr}" }
  end

  test "value debe estar entre 0 y 1" do
    assert_not build_discount(value: -0.1).valid?
    assert_not build_discount(value: 1.1).valid?

    assert build_discount(value: 0).valid?
    assert build_discount(value: 1).valid?
  end

  test "un descuento puede aplicarse a varios productos" do
    product_b = @provider.products.create!(name: "Otro", price: 100, stock: 1)
    discount = Discount.create!(value: 0.5, start_date: Date.today, end_date: Date.tomorrow,
                                products: [ @product, product_b ])

    assert_includes discount.products, @product
    assert_includes discount.products, product_b
  end

  test "un producto puede pertenecer a varios descuentos" do
    discount_a = @product.discounts.create!(value: 0.1, start_date: Date.today, end_date: Date.tomorrow)
    discount_b = @product.discounts.create!(value: 0.2, start_date: Date.today, end_date: Date.tomorrow)

    assert_includes @product.discounts, discount_a
    assert_includes @product.discounts, discount_b
  end

  test "no admite el mismo descuento dos veces sobre un producto" do
    discount = Discount.create!(value: 0.5, start_date: Date.today, end_date: Date.tomorrow)
    discount.products << @product

    assert_raises ActiveRecord::RecordNotUnique do
      discount.products << @product
    end
  end

  test "end_date debe ser mayor o igual a start_date" do
    assert_not build_discount(value: 0.5, start_date: Date.tomorrow, end_date: Date.today).valid?
  end

  test "active? considera solo el rango de fechas vigente" do
    assert build_discount(value: 0.5, start_date: Date.yesterday, end_date: Date.tomorrow).active?
    assert_not build_discount(value: 0.5, start_date: Date.tomorrow, end_date: Date.today + 5).active?
  end

  test "active scope devuelve solo descuentos vigentes" do
    @product.discounts.create!(value: 0.2, start_date: Date.yesterday, end_date: Date.tomorrow)
    @product.discounts.create!(value: 0.3, start_date: Date.tomorrow, end_date: Date.today + 5)

    assert_equal 1, @product.discounts.active.count
  end

  test "discounted_price aplica el valor sobre el precio base del producto" do
    discount = @product.discounts.create!(value: 0.5, start_date: Date.yesterday, end_date: Date.tomorrow)

    assert_equal 50, discount.discounted_price(@product)
  end
end
