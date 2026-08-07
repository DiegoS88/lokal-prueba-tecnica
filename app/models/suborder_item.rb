class SuborderItem < ApplicationRecord
  belongs_to :suborder
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :line_total, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validate :line_total_matches

  private

  def line_total_matches
    return if unit_price.nil? || quantity.nil?
    return if line_total == unit_price * quantity

    errors.add(:line_total, "debe ser el resultado de unit_price x quantity")
  end
end
