class Currency < ApplicationRecord
  validates :code, :name, presence: true
  validates :precision, presence: true, numericality: { only_integer: true, greater_than: 0 }

  def self.default
    order(:id).first
  end

  def self.divisor
    default&.divisor || 1000
  end

  def self.precision
    default&.precision || 3
  end

  # Factor por el que dividir un monto guardado para obtener unidades de moneda.
  def divisor
    10**precision
  end
end
