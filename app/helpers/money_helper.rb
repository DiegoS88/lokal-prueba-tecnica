module MoneyHelper
  # Formatea céntimos como moneda. Evita repetir `number_to_currency(cents / 100.0)`
  # en cada vista.
  def money(cents)
    number_to_currency(cents.to_i / 100.0)
  end
end
