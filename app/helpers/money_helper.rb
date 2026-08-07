module MoneyHelper
  # Formatea un monto entero (precio base) como moneda usando la moneda activa
  # (CLP con precisión 3): divide por el divisor y muestra con esa precisión.
  def money(amount)
    number_to_currency(amount.to_i / (10.0 ** Currency.precision), precision: Currency.precision)
  end
end
