class Product < ApplicationRecord
  belongs_to :provider

  validates :name, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :available, -> { where("stock > ?", 0) }

  def price_in_currency
    price / Currency.divisor
  end
end
