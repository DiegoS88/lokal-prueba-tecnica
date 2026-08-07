class Product < ApplicationRecord
  belongs_to :provider
  has_many :discount_products
  has_many :discounts, through: :discount_products

  def active_discount
    discounts.active.order(:end_date).first
  end

  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :available, -> { where("stock > ?", 0) }

  def can_supply?(quantity)
    quantity >= 0 && quantity <= stock
  end

  def price_in_currency
    price / Currency.divisor
  end
end
