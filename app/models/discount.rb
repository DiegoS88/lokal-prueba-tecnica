class Discount < ApplicationRecord
  has_many :discount_products, dependent: :destroy
  has_many :products, through: :discount_products

  validates :value, presence: true,
                    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :start_date, presence: true
  validates :end_date, presence: true

  validate :end_date_after_start_date

  scope :active, -> { where(":today BETWEEN start_date AND end_date", today: Date.current) }

  def active?
    (start_date..end_date).cover?(Date.current)
  end

  def discounted_price(product)
    (product.price * (1 - value)).round
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    errors.add(:end_date, :greater_than_or_equal_to, compare_to: start_date) if end_date < start_date
  end
end