class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :line_total_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :line_total_matches

  private

  def line_total_matches
    return if unit_price_cents.nil? || quantity.nil?
    return if line_total_cents == unit_price_cents * quantity

    errors.add(:line_total_cents, "debe ser el resultado de unit_price x quantity")
  end
end
