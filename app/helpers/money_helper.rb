module MoneyHelper
  # Formatea un monto entero (precio base) como moneda dividiendo por 1000.
  def money(cents)
    number_to_currency(cents.to_i / 1000.0)
  end
end
