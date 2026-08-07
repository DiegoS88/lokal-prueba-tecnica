require "test_helper"

class CurrencyTest < ActiveSupport::TestCase
  def setup
    @currency = Currency.create!(code: "CLP", precision: 3, name: "Peso Chileno")
  end

  test "el divisor deriva de la precisión" do
    assert_equal 1000, @currency.divisor
  end

  test "no permite precisión cero o negativa" do
    bad = Currency.new(code: "X", precision: 0, name: "Mala")

    assert_not bad.valid?
    assert bad.errors[:precision].any?
  end
end
